using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using SmartFoundation.Mvc.Helpers;
using SmartFoundation.UI.ViewModels.SmartForm;
using SmartFoundation.UI.ViewModels.SmartPage;
using SmartFoundation.UI.ViewModels.SmartTable;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.Encodings.Web;

namespace SmartFoundation.Mvc.Controllers.Tickets
{
    public partial class TicketController : Controller
    {
        public async Task<IActionResult> ServiceCatalogueList()
        {
            if (!InitPageContext(out var redirect))
                return redirect!;

            if (string.IsNullOrWhiteSpace(usersId))
                return RedirectToAction("Index", "Login", new { logout = 4 });

            ControllerName = nameof(TicketController).Replace("Controller", "");
            PageName = "ServiceCatalogueList";

            DataSet ds = await _mastersServies.GetDataLoadDataSetAsync(
                PageName,
                IdaraId,
                usersId,
                HostName,
                null,
                null);

            SplitDataSet(ds);

            if (IsFailedServiceCatalogueDataLoad(dt1) || !HasServiceCatalogueProjection(dt1))
            {
                var fallbackTable = await TryLoadServiceCatalogueFallbackAsync();
                if (fallbackTable != null && fallbackTable.Columns.Count > 0)
                    dt1 = fallbackTable;
            }

            if (permissionTable is null || permissionTable.Rows.Count == 0)
            {
                TempData["Error"] = "تم رصد دخول غير مصرح به انت لاتملك صلاحية للوصول الى هذه الصفحة";
                return RedirectToAction("Index", "Home");
            }

            bool canInsertService = false;
            bool canUpdateService = false;
            bool canDeleteService = false;
            bool canManageRoutingRules = false;
            bool canManageSlaPolicies = false;

            foreach (DataRow row in permissionTable.Rows)
            {
                var permission = row["permissionTypeName_E"]?.ToString()?.Trim().ToUpperInvariant();
                if (permission == "INSERTSERVICE") canInsertService = true;
                if (permission == "UPDATESERVICE") canUpdateService = true;
                if (permission == "DELETESERVICE") canDeleteService = true;
                if (permission == "MANAGEROUTINGRULES") canManageRoutingRules = true;
                if (permission == "MANAGESLAPOLICIES") canManageSlaPolicies = true;
            }

            var ticketClassTask = GetDDLAsync("ticketClassName_A", "ticketClassID", "2", "TicketClassDDL");
            var priorityTask = GetDDLAsync("priorityName_A", "priorityID", "2", "PriorityDDL");

            await Task.WhenAll(ticketClassTask, priorityTask);

            var ticketClassOptions = ticketClassTask.Result;
            if (!HasUsableOptions(ticketClassOptions))
            {
                ticketClassOptions = await GetTicketDdlOptionsAsync(
                    "TicketClassDDL",
                    "ticketClassID",
                    "ticketClassName_A",
                    "اختر فئة التذكرة");
            }

            var priorityOptions = priorityTask.Result;
            if (!HasUsableOptions(priorityOptions))
            {
                priorityOptions = await GetTicketDdlOptionsAsync(
                    "PriorityDDL",
                    "priorityID",
                    "priorityName_A",
                    "اختر الأولوية");
            }

            var model = BuildServiceCatalogueTable(
                dt1,
                ticketClassOptions,
                priorityOptions,
                canInsertService,
                canUpdateService,
                canDeleteService,
                canManageRoutingRules,
                canManageSlaPolicies);

            int totalServices = model.Rows.Count;
            int activeServices = model.Rows.Count(row => IsTruthy(GetDictionaryValue(row, "serviceActive")));

            var page = new SmartPageViewModel
            {
                PageTitle = "دليل الخدمات",
                PanelTitle = $"دليل الخدمات ({activeServices} نشطة من أصل {totalServices})",
                PanelIcon = "fa-solid fa-concierge-bell",
                TableDS = model
            };

            return View("ServiceCatalogueList", page);
        }

        [HttpGet]
        public async Task<IActionResult> ServiceCatalogueDetailModal(long serviceId)
        {
            if (!InitPageContext(out _))
                return Content(BuildModalErrorHtml("انتهت الجلسة. أعد تحميل الصفحة ثم حاول مرة أخرى."), "text/html; charset=utf-8");

            ControllerName = nameof(TicketController).Replace("Controller", "");
            PageName = "ServiceCatalogueList";

            var service = await GetServiceCatalogueDetailAsync(serviceId);
            if (service == null)
                return Content(BuildModalErrorHtml("لم يتم العثور على الخدمة المطلوبة."), "text/html; charset=utf-8");

            return Content(BuildServiceCatalogueDetailHtml(service), "text/html; charset=utf-8");
        }

        [HttpGet]
        public async Task<IActionResult> ServiceCatalogueRoutingForm(long serviceId)
        {
            if (!InitPageContext(out _))
                return Content(BuildModalErrorHtml("انتهت الجلسة. أعد تحميل الصفحة ثم حاول مرة أخرى."), "text/html; charset=utf-8");

            ControllerName = nameof(TicketController).Replace("Controller", "");
            PageName = "ServiceCatalogueList";

            if (!await HasMenuPermissionAsync(PageName, "MANAGEROUTINGRULES"))
                return Content(BuildModalErrorHtml("لا تملك صلاحية إدارة التوجيه لهذه الخدمة."), "text/html; charset=utf-8");

            var serviceTask = GetServiceCatalogueDetailAsync(serviceId);
            var dsdTask = GetServiceCatalogueDsdOptionsAsync();
            var distributorTask = GetServiceCatalogueDistributorOptionsAsync();

            await Task.WhenAll(serviceTask, dsdTask, distributorTask);

            var service = serviceTask.Result;
            if (service == null)
                return Content(BuildModalErrorHtml("لم يتم العثور على الخدمة المطلوبة."), "text/html; charset=utf-8");

            return Content(
                BuildServiceCatalogueRoutingFormHtml(service, dsdTask.Result, distributorTask.Result),
                "text/html; charset=utf-8");
        }

        [HttpPost]
        public async Task<IActionResult> ServiceCatalogueSaveRoutingRule(ServiceCatalogueRoutingFormModel form)
        {
            if (!InitPageContext(out var redirect))
                return redirect!;

            if (!await HasMenuPermissionAsync("ServiceCatalogueList", "MANAGEROUTINGRULES"))
            {
                TempData["Error"] = "عفوا لاتملك صلاحية لهذه العملية";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            if (!TryGetCurrentIdaraId(out var idaraId))
            {
                TempData["Error"] = "تعذر تحديد الإدارة الحالية.";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            if (form.serviceID <= 0 || !form.targetDSDID_FK.HasValue)
            {
                TempData["Error"] = "بيانات التوجيه غير مكتملة.";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            var service = await GetServiceCatalogueDetailAsync(form.serviceID);
            if (service == null)
            {
                TempData["Error"] = "لم يتم العثور على الخدمة المطلوبة.";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            if (!IsTruthy(GetDictionaryValue(service, "serviceActive")))
            {
                TempData["Error"] = "لا يمكن تعديل التوجيه لخدمة غير نشطة.";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            try
            {
                var activeRoutingRuleId = TryGetInt64(GetDictionaryValue(service, "activeRoutingRuleID"));
                if (activeRoutingRuleId.HasValue)
                {
                    var closeResult = await ExecuteServiceCatalogueStoredProcedureAsync(
                        "CLOSE_ROUTING_RULE",
                        new Dictionary<string, object?>
                        {
                            ["serviceID"] = activeRoutingRuleId.Value,
                            ["entryData"] = usersId,
                            ["hostName"] = HostName
                        });

                    if (!closeResult.Success)
                    {
                        TempData["Error"] = closeResult.Message;
                        return RedirectToAction(nameof(ServiceCatalogueList));
                    }
                }

                var result = await ExecuteServiceCatalogueStoredProcedureAsync(
                    "INSERT_ROUTING_RULE",
                    new Dictionary<string, object?>
                    {
                        ["serviceID"] = form.serviceID,
                        ["idaraID_FK"] = idaraId,
                        ["targetDSDID_FK"] = form.targetDSDID_FK,
                        ["queueDistributorID_FK"] = form.queueDistributorID_FK,
                        ["changeReason"] = NormalizeNullableString(form.changeReason),
                        ["approvedByUserID"] = TryGetCurrentUserId(),
                        ["effectiveFrom"] = form.effectiveFrom ?? DateTime.Now,
                        ["entryData"] = usersId,
                        ["hostName"] = HostName
                    });

                TempData[result.Success ? "Success" : "Error"] = result.Message;
            }
            catch (Exception ex)
            {
                TempData["Error"] = $"تعذر حفظ التوجيه: {ex.Message}";
            }

            return RedirectToAction(nameof(ServiceCatalogueList));
        }

        [HttpGet]
        public async Task<IActionResult> ServiceCatalogueSlaForm(long serviceId)
        {
            if (!InitPageContext(out _))
                return Content(BuildModalErrorHtml("انتهت الجلسة. أعد تحميل الصفحة ثم حاول مرة أخرى."), "text/html; charset=utf-8");

            ControllerName = nameof(TicketController).Replace("Controller", "");
            PageName = "ServiceCatalogueList";

            if (!await HasMenuPermissionAsync(PageName, "MANAGESLAPOLICIES"))
                return Content(BuildModalErrorHtml("لا تملك صلاحية إدارة سياسات SLA لهذه الخدمة."), "text/html; charset=utf-8");

            var serviceTask = GetServiceCatalogueDetailAsync(serviceId);
            var priorityTask = GetDDLAsync("priorityName_A", "priorityID", "2", "PriorityDDL");
            var policiesTask = GetServiceCatalogueSlaPoliciesAsync(serviceId);

            await Task.WhenAll(serviceTask, priorityTask, policiesTask);

            var service = serviceTask.Result;
            if (service == null)
                return Content(BuildModalErrorHtml("لم يتم العثور على الخدمة المطلوبة."), "text/html; charset=utf-8");

            var priorityOptions = priorityTask.Result;
            if (!HasUsableOptions(priorityOptions))
            {
                priorityOptions = await GetTicketDdlOptionsAsync(
                    "PriorityDDL",
                    "priorityID",
                    "priorityName_A",
                    "اختر الأولوية");
            }

            return Content(
                BuildServiceCatalogueSlaFormHtml(service, priorityOptions, policiesTask.Result),
                "text/html; charset=utf-8");
        }

        [HttpPost]
        public async Task<IActionResult> ServiceCatalogueSaveSlaPolicy(ServiceCatalogueSlaFormModel form)
        {
            if (!InitPageContext(out var redirect))
                return redirect!;

            if (!await HasMenuPermissionAsync("ServiceCatalogueList", "MANAGESLAPOLICIES"))
            {
                TempData["Error"] = "عفوا لاتملك صلاحية لهذه العملية";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            if (!TryGetCurrentIdaraId(out var idaraId))
            {
                TempData["Error"] = "تعذر تحديد الإدارة الحالية.";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            if (form.serviceID <= 0 || !form.priorityID_FK.HasValue)
            {
                TempData["Error"] = "بيانات SLA غير مكتملة.";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            try
            {
                var result = await ExecuteServiceCatalogueStoredProcedureAsync(
                    "UPSERT_SLA_POLICY",
                    new Dictionary<string, object?>
                    {
                        ["serviceID"] = form.serviceID,
                        ["idaraID_FK"] = idaraId,
                        ["priorityID_FK"] = form.priorityID_FK,
                        ["firstResponseTargetMinutes"] = form.firstResponseTargetMinutes,
                        ["assignmentTargetMinutes"] = form.assignmentTargetMinutes,
                        ["operationalCompletionTargetMinutes"] = form.operationalCompletionTargetMinutes,
                        ["finalClosureTargetMinutes"] = form.finalClosureTargetMinutes,
                        ["entryData"] = usersId,
                        ["hostName"] = HostName
                    });

                TempData[result.Success ? "Success" : "Error"] = result.Message;
            }
            catch (Exception ex)
            {
                TempData["Error"] = $"تعذر حفظ سياسة SLA: {ex.Message}";
            }

            return RedirectToAction(nameof(ServiceCatalogueList));
        }

        [HttpPost]
        public async Task<IActionResult> ServiceCatalogueCreate(ServiceCatalogueServiceFormModel form)
        {
            if (!InitPageContext(out var redirect))
                return redirect!;

            if (!await HasMenuPermissionAsync("ServiceCatalogueList", "INSERTSERVICE"))
            {
                TempData["Error"] = "عفوا لاتملك صلاحية لهذه العملية";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            if (!TryGetCurrentIdaraId(out var idaraId))
            {
                TempData["Error"] = "تعذر تحديد الإدارة الحالية.";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            if (string.IsNullOrWhiteSpace(form.serviceName_A))
            {
                TempData["Error"] = "اسم الخدمة بالعربية مطلوب.";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            try
            {
                var result = await ExecuteServiceCatalogueStoredProcedureAsync(
                    "INSERT_SERVICE",
                    new Dictionary<string, object?>
                    {
                        ["serviceCode"] = NormalizeNullableString(form.serviceCode),
                        ["serviceName_A"] = NormalizeNullableString(form.serviceName_A),
                        ["serviceName_E"] = NormalizeNullableString(form.serviceName_E),
                        ["serviceDesc"] = NormalizeNullableString(form.serviceDesc),
                        ["idaraID_FK"] = idaraId,
                        ["ticketClassID_FK"] = form.ticketClassID_FK,
                        ["defaultPriorityID_FK"] = form.defaultPriorityID_FK,
                        ["requiresLocation"] = form.requiresLocation,
                        ["allowsChildTickets"] = form.allowsChildTickets,
                        ["requiresQualityReview"] = form.requiresQualityReview,
                        ["entryData"] = usersId,
                        ["hostName"] = HostName
                    });

                TempData[result.Success ? "Success" : "Error"] = result.Message;
            }
            catch (Exception ex)
            {
                TempData["Error"] = $"تعذر إنشاء الخدمة: {ex.Message}";
            }

            return RedirectToAction(nameof(ServiceCatalogueList));
        }

        [HttpPost]
        public async Task<IActionResult> ServiceCatalogueUpdate(ServiceCatalogueServiceFormModel form)
        {
            if (!InitPageContext(out var redirect))
                return redirect!;

            if (!await HasMenuPermissionAsync("ServiceCatalogueList", "UPDATESERVICE"))
            {
                TempData["Error"] = "عفوا لاتملك صلاحية لهذه العملية";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            if (form.serviceID <= 0)
            {
                TempData["Error"] = "معرف الخدمة مطلوب للتحديث.";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            try
            {
                var result = await ExecuteServiceCatalogueStoredProcedureAsync(
                    "UPDATE_SERVICE",
                    new Dictionary<string, object?>
                    {
                        ["serviceID"] = form.serviceID,
                        ["serviceCode"] = NormalizeNullableString(form.serviceCode),
                        ["serviceName_A"] = NormalizeNullableString(form.serviceName_A),
                        ["serviceName_E"] = NormalizeNullableString(form.serviceName_E),
                        ["serviceDesc"] = NormalizeNullableString(form.serviceDesc),
                        ["ticketClassID_FK"] = form.ticketClassID_FK,
                        ["defaultPriorityID_FK"] = form.defaultPriorityID_FK,
                        ["requiresLocation"] = form.requiresLocation,
                        ["allowsChildTickets"] = form.allowsChildTickets,
                        ["requiresQualityReview"] = form.requiresQualityReview,
                        ["entryData"] = usersId,
                        ["hostName"] = HostName
                    });

                TempData[result.Success ? "Success" : "Error"] = result.Message;
            }
            catch (Exception ex)
            {
                TempData["Error"] = $"تعذر تحديث الخدمة: {ex.Message}";
            }

            return RedirectToAction(nameof(ServiceCatalogueList));
        }

        [HttpPost]
        public async Task<IActionResult> ServiceCatalogueDelete(ServiceCatalogueDeleteFormModel form)
        {
            if (!InitPageContext(out var redirect))
                return redirect!;

            if (!await HasMenuPermissionAsync("ServiceCatalogueList", "DELETESERVICE"))
            {
                TempData["Error"] = "عفوا لاتملك صلاحية لهذه العملية";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            if (form.serviceID <= 0)
            {
                TempData["Error"] = "معرف الخدمة مطلوب للحذف.";
                return RedirectToAction(nameof(ServiceCatalogueList));
            }

            try
            {
                var result = await ExecuteServiceCatalogueStoredProcedureAsync(
                    "DELETE_SERVICE",
                    new Dictionary<string, object?>
                    {
                        ["serviceID"] = form.serviceID,
                        ["entryData"] = usersId,
                        ["hostName"] = HostName
                    });

                TempData[result.Success ? "Success" : "Error"] = result.Message;
            }
            catch (Exception ex)
            {
                TempData["Error"] = $"تعذر حذف الخدمة: {ex.Message}";
            }

            return RedirectToAction(nameof(ServiceCatalogueList));
        }

        private SmartTableDsModel BuildServiceCatalogueTable(
            DataTable? table,
            List<OptionItem> ticketClassOptions,
            List<OptionItem> priorityOptions,
            bool canInsertService,
            bool canUpdateService,
            bool canDeleteService,
            bool canManageRoutingRules,
            bool canManageSlaPolicies)
        {
            var rows = new List<Dictionary<string, object?>>();

            if (table != null)
            {
                foreach (DataRow dataRow in table.Rows)
                {
                    var row = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
                    foreach (DataColumn column in table.Columns)
                        row[column.ColumnName] = dataRow[column] == DBNull.Value ? null : dataRow[column];

                    row["serviceName_A"] = GetPreferredDisplayName(
                        GetDictionaryValue(row, "serviceName_A"),
                        GetDictionaryValue(row, "serviceName_E"));
                    row["priorityName_A"] = GetPreferredDisplayName(
                        GetDictionaryValue(row, "priorityName_A"),
                        GetDictionaryValue(row, "priorityName_E"));
                    row["departmentName"] = NormalizeDisplayValue(GetDictionaryValue(row, "departmentName"), IdaraName);
                    row["divisionSectionName"] = NormalizeDisplayValue(GetDictionaryValue(row, "divisionSectionName"), "-");
                    row["serviceActive"] = IsTruthy(GetDictionaryValue(row, "serviceActive")) ? 1 : 0;
                    row["serviceStatusText"] = IsTruthy(GetDictionaryValue(row, "serviceActive")) ? "نشطة" : "غير نشطة";

                    rows.Add(row);
                }
            }

            var toolbar = new TableToolbarConfig
            {
                ShowAdd = canInsertService,
                ShowEdit = canUpdateService,
                ShowDelete = canDeleteService,
                ShowRefresh = true,
                ShowColumns = true,
                ShowExportExcel = true,
                ShowSearch = true
            };

            if (canInsertService)
            {
                toolbar.Add = new TableAction
                {
                    Label = "إضافة خدمة",
                    Icon = "fa fa-plus",
                    Color = "success",
                    OpenModal = true,
                    ModalTitle = "إضافة خدمة",
                    OpenForm = BuildServiceCatalogueServiceForm(
                        "serviceCatalogueInsertForm",
                        "إضافة خدمة جديدة",
                        $"/{ControllerName}/ServiceCatalogueCreate",
                        ticketClassOptions,
                        priorityOptions,
                        includeServiceId: false)
                };
            }

            if (canUpdateService)
            {
                toolbar.Edit = new TableAction
                {
                    Label = "تعديل الخدمة",
                    Icon = "fa fa-pen-to-square",
                    Color = "info",
                    RequireSelection = true,
                    MinSelection = 1,
                    MaxSelection = 1,
                    IsEdit = true,
                    OpenModal = true,
                    ModalTitle = "تعديل الخدمة",
                    OpenForm = BuildServiceCatalogueServiceForm(
                        "serviceCatalogueEditForm",
                        "تعديل الخدمة",
                        $"/{ControllerName}/ServiceCatalogueUpdate",
                        ticketClassOptions,
                        priorityOptions,
                        includeServiceId: true)
                };
            }

            if (canDeleteService)
            {
                toolbar.Delete = new TableAction
                {
                    Label = "حذف الخدمة",
                    Icon = "fa fa-trash",
                    Color = "danger",
                    RequireSelection = true,
                    MinSelection = 1,
                    MaxSelection = 1,
                    IsEdit = true,
                    OpenModal = true,
                    ModalTitle = "تأكيد الحذف",
                    ModalMessage = "سيتم تعطيل الخدمة الحالية. هذا الإجراء مرصود ويمكن التراجع عنه من قاعدة البيانات فقط.",
                    ModalMessageIcon = "fa-solid fa-triangle-exclamation",
                    ModalMessageClass = "bg-red-50 text-red-700",
                    OpenForm = new FormConfig
                    {
                        FormId = "serviceCatalogueDeleteForm",
                        Title = "تأكيد حذف الخدمة",
                        Method = "post",
                        ActionUrl = $"/{ControllerName}/ServiceCatalogueDelete",
                        Fields = new List<FieldConfig>
                        {
                            new() { Name = "serviceID", Type = "hidden" }
                        },
                        Buttons = BuildModalButtons("حذف", "danger", "fa fa-trash")
                    }
                };
            }

            if (canManageRoutingRules)
            {
                toolbar.CustomActions.Add(new TableAction
                {
                    Label = "إدارة التوجيه",
                    Icon = "fa fa-diagram-project",
                    Color = "warning",
                    RequireSelection = true,
                    MinSelection = 1,
                    MaxSelection = 1,
                    OpenModal = true,
                    ModalTitle = "إدارة التوجيه",
                    FormUrl = $"/{ControllerName}/ServiceCatalogueRoutingForm?serviceId={{serviceID}}"
                });
            }

            if (canManageSlaPolicies)
            {
                toolbar.CustomActions.Add(new TableAction
                {
                    Label = "إدارة SLA",
                    Icon = "fa fa-stopwatch",
                    Color = "secondary",
                    RequireSelection = true,
                    MinSelection = 1,
                    MaxSelection = 1,
                    OpenModal = true,
                    ModalTitle = "إدارة سياسات SLA",
                    FormUrl = $"/{ControllerName}/ServiceCatalogueSlaForm?serviceId={{serviceID}}"
                });
            }

            var model = new SmartTableDsModel
            {
                PageTitle = "دليل الخدمات",
                PanelTitle = "الخدمات المتاحة",
                Columns = new List<TableColumn>
                {
                    new() { Field = "serviceCode", Label = "الكود", Width = "96px", MinWidth = "96px", Align = "left" },
                    new() { Field = "serviceName_A", Label = "اسم الخدمة", Align = "left" },
                    new() { Field = "departmentName", Label = "الإدارة/القسم", Align = "left" },
                    new() { Field = "divisionSectionName", Label = "الشعبة / القسم", Align = "left" },
                    new() { Field = "priorityName_A", Label = "الأولوية", Align = "left" },
                    new() { Field = "serviceActive", Label = "الحالة", Align = "center", Width = "72px", MinWidth = "72px" }
                },
                Rows = rows,
                RowIdField = "serviceID",
                PageSize = 10,
                PageSizes = new List<int> { 10, 25, 50, 100 },
                Searchable = true,
                SearchPlaceholder = "ابحث عن خدمة...",
                AllowExport = true,
                ShowPageSizeSelector = true,
                EnableCellCopy = true,
                ShowColumnVisibility = true,
                QuickSearchFields = new List<string> { "serviceCode", "serviceName_A", "departmentName", "divisionSectionName" },
                Toolbar = toolbar,
                RowActions = new List<TableAction>
                {
                    new()
                    {
                        Label = string.Empty,
                        Icon = "fa fa-eye",
                        Color = "secondary",
                        Placement = TableActionPlacement.RowEnd,
                        OpenModal = true,
                        ModalTitle = "تفاصيل الخدمة",
                        FormUrl = $"/{ControllerName}/ServiceCatalogueDetailModal?serviceId={{serviceID}}"
                    }
                },
                ShowToolbar = true,
                EnablePagination = true,
                StorageKey = "ServiceCatalogueList:Main:v1",
                Selectable = true
            };

            model.StyleRules = new List<TableStyleRule>
            {
                new()
                {
                    Target = "cell",
                    Field = "priorityName_A",
                    Op = "eq",
                    Value = "حرج",
                    Priority = 2,
                    PillEnabled = true,
                    PillField = "priorityName_A",
                    PillTextField = "priorityName_A",
                    PillCssClass = "pill pill-red",
                    PillMode = "replace"
                },
                new()
                {
                    Target = "cell",
                    Field = "priorityName_A",
                    Op = "eq",
                    Value = "عالي",
                    Priority = 2,
                    PillEnabled = true,
                    PillField = "priorityName_A",
                    PillTextField = "priorityName_A",
                    PillCssClass = "pill pill-orange",
                    PillMode = "replace"
                },
                new()
                {
                    Target = "cell",
                    Field = "priorityName_A",
                    Op = "eq",
                    Value = "متوسط",
                    Priority = 2,
                    PillEnabled = true,
                    PillField = "priorityName_A",
                    PillTextField = "priorityName_A",
                    PillCssClass = "pill pill-blue",
                    PillMode = "replace"
                },
                new()
                {
                    Target = "cell",
                    Field = "priorityName_A",
                    Op = "eq",
                    Value = "منخفض",
                    Priority = 2,
                    PillEnabled = true,
                    PillField = "priorityName_A",
                    PillTextField = "priorityName_A",
                    PillCssClass = "pill pill-green",
                    PillMode = "replace"
                },
                new()
                {
                    Target = "cell",
                    Field = "serviceActive",
                    Op = "eq",
                    Value = "1",
                    Priority = 1,
                    PillEnabled = true,
                    IconOnly = true,
                    IconOnlyCssClass = "sf-icon-only sf-icon-only--success",
                    PillTitle = "نشطة",
                    PillSvg = SfIcons.Check
                },
                new()
                {
                    Target = "cell",
                    Field = "serviceActive",
                    Op = "eq",
                    Value = "0",
                    Priority = 1,
                    PillEnabled = true,
                    IconOnly = true,
                    IconOnlyCssClass = "sf-icon-only sf-icon-only--danger",
                    PillTitle = "غير نشطة",
                    PillSvg = SfIcons.Close
                }
            };

            return model;
        }

        private FormConfig BuildServiceCatalogueServiceForm(
            string formId,
            string title,
            string actionUrl,
            List<OptionItem> ticketClassOptions,
            List<OptionItem> priorityOptions,
            bool includeServiceId)
        {
            var fields = new List<FieldConfig>();

            if (includeServiceId)
                fields.Add(new FieldConfig { Name = "serviceID", Type = "hidden" });

            fields.AddRange(new List<FieldConfig>
            {
                new() { Label = "كود الخدمة", Name = "serviceCode", Type = "text", Required = true, ColCss = "6", MaxLength = 100 },
                new() { Label = "اسم الخدمة (عربي)", Name = "serviceName_A", Type = "text", Required = true, ColCss = "6", MaxLength = 500, TextMode = "arabic" },
                new() { Label = "اسم الخدمة (إنجليزي)", Name = "serviceName_E", Type = "text", ColCss = "6", MaxLength = 500, TextMode = "english" },
                new() { Label = "الوصف", Name = "serviceDesc", Type = "textarea", ColCss = "12", MaxLength = 2000 },
                new() { Label = "فئة التذكرة", Name = "ticketClassID_FK", Type = "select", Options = ticketClassOptions, ColCss = "6", Select2 = true },
                new() { Label = "الأولوية الافتراضية", Name = "defaultPriorityID_FK", Type = "select", Options = priorityOptions, ColCss = "6", Select2 = true },
                new() { Label = "يتطلب موقع", Name = "requiresLocation", Type = "checkbox", ColCss = "4" },
                new() { Label = "يسمح بتذاكر فرعية", Name = "allowsChildTickets", Type = "checkbox", ColCss = "4" },
                new() { Label = "يتطلب مراجعة جودة", Name = "requiresQualityReview", Type = "checkbox", ColCss = "4" }
            });

            return new FormConfig
            {
                FormId = formId,
                Title = title,
                Method = "post",
                ActionUrl = actionUrl,
                Fields = fields,
                Buttons = BuildModalButtons("حفظ", "success", "fa fa-check")
            };
        }

        private List<FormButtonConfig> BuildModalButtons(string submitText, string submitColor, string submitIcon)
        {
            return new List<FormButtonConfig>
            {
                new() { Text = submitText, Type = "submit", Color = submitColor, Icon = submitIcon },
                new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" }
            };
        }

        private async Task<DataTable?> TryLoadServiceCatalogueFallbackAsync()
        {
            try
            {
                const string sql = @"
SELECT
      s.[serviceID]
    , s.[serviceCode]
    , COALESCE(NULLIF(LTRIM(RTRIM(s.[serviceName_A])), N''), s.[serviceName_E]) AS [serviceName_A]
    , s.[serviceName_E]
    , s.[serviceDesc]
    , s.[idaraID_FK]
    , s.[ticketClassID_FK]
    , tc.[ticketClassName_A]
    , tc.[ticketClassName_E]
    , s.[defaultPriorityID_FK]
    , COALESCE(NULLIF(LTRIM(RTRIM(p.[priorityName_A])), N''), p.[priorityName_E]) AS [priorityName_A]
    , p.[priorityName_E]
    , s.[requiresLocation]
    , s.[allowsChildTickets]
    , s.[requiresQualityReview]
    , s.[serviceActive]
    , COALESCE(NULLIF(LTRIM(RTRIM(routeDsd.[DepartmentName])), N''), idara.[IdaraName], N'-') AS [departmentName]
    , CASE
          WHEN NULLIF(LTRIM(RTRIM(routeDsd.[DivisonName])), N'') IS NOT NULL
               AND NULLIF(LTRIM(RTRIM(routeDsd.[SectionName])), N'') IS NOT NULL
              THEN routeDsd.[DivisonName] + N' / ' + routeDsd.[SectionName]
          WHEN NULLIF(LTRIM(RTRIM(routeDsd.[DivisonName])), N'') IS NOT NULL
              THEN routeDsd.[DivisonName]
          WHEN NULLIF(LTRIM(RTRIM(routeDsd.[SectionName])), N'') IS NOT NULL
              THEN routeDsd.[SectionName]
          WHEN NULLIF(LTRIM(RTRIM(routeDsd.[DepartmentName])), N'') IS NOT NULL
              THEN routeDsd.[DepartmentName]
          ELSE N'-'
      END AS [divisionSectionName]
    , activeRoute.[serviceRoutingRuleID] AS [activeRoutingRuleID]
    , activeRoute.[targetDSDID_FK] AS [activeTargetDSDID]
    , activeRoute.[effectiveFrom] AS [routingEffectiveFrom]
    , routeDsd.[DepartmentName] AS [routingDepartmentName]
    , routeDsd.[DivisonName] AS [routingDivisionName]
    , routeDsd.[SectionName] AS [routingSectionName]
    , COALESCE(NULLIF(LTRIM(RTRIM(dist.[distributorName_A])), N''), dist.[distributorName_E]) AS [routingDistributorName]
    , defaultSla.[serviceSLAPolicyID] AS [slaPolicyID]
    , defaultSla.[priorityID_FK] AS [slaPriorityID_FK]
    , COALESCE(NULLIF(LTRIM(RTRIM(slaPriority.[priorityName_A])), N''), slaPriority.[priorityName_E]) AS [slaPriorityName]
    , defaultSla.[firstResponseTargetMinutes]
    , defaultSla.[assignmentTargetMinutes]
    , defaultSla.[operationalCompletionTargetMinutes]
    , defaultSla.[finalClosureTargetMinutes]
FROM [Tickets].[Service] s
LEFT JOIN [Tickets].[TicketClass] tc
    ON tc.[ticketClassID] = s.[ticketClassID_FK]
LEFT JOIN [Tickets].[Priority] p
    ON p.[priorityID] = s.[defaultPriorityID_FK]
LEFT JOIN dbo.[V_GetListIdara] idara
    ON idara.[IdaraID] = s.[idaraID_FK]
OUTER APPLY
(
    SELECT TOP (1)
          rr.[serviceRoutingRuleID]
        , rr.[targetDSDID_FK]
        , rr.[queueDistributorID_FK]
        , rr.[effectiveFrom]
    FROM [Tickets].[ServiceRoutingRule] rr
    WHERE rr.[serviceID_FK] = s.[serviceID]
      AND rr.[serviceRoutingRuleActive] = 1
      AND rr.[effectiveFrom] <= GETDATE()
      AND (rr.[effectiveTo] IS NULL OR rr.[effectiveTo] > GETDATE())
    ORDER BY rr.[effectiveFrom] DESC, rr.[serviceRoutingRuleID] DESC
) activeRoute
LEFT JOIN dbo.[V_GetFullStructureForDSD] routeDsd
    ON routeDsd.[DSDID] = activeRoute.[targetDSDID_FK]
LEFT JOIN dbo.[Distributor] dist
    ON dist.[distributorID] = activeRoute.[queueDistributorID_FK]
   AND ISNULL(dist.[distributorActive], 0) = 1
OUTER APPLY
(
    SELECT TOP (1)
          sp.[serviceSLAPolicyID]
        , sp.[priorityID_FK]
        , sp.[firstResponseTargetMinutes]
        , sp.[assignmentTargetMinutes]
        , sp.[operationalCompletionTargetMinutes]
        , sp.[finalClosureTargetMinutes]
    FROM [Tickets].[ServiceSLAPolicy] sp
    WHERE sp.[serviceID_FK] = s.[serviceID]
      AND sp.[slaPolicyActive] = 1
      AND sp.[priorityID_FK] = s.[defaultPriorityID_FK]
    ORDER BY sp.[effectiveFrom] DESC, sp.[serviceSLAPolicyID] DESC
) defaultSla
LEFT JOIN [Tickets].[Priority] slaPriority
    ON slaPriority.[priorityID] = defaultSla.[priorityID_FK]
WHERE (s.[idaraID_FK] = @idaraID OR s.[idaraID_FK] IS NULL)
ORDER BY s.[serviceActive] DESC, s.[serviceID] DESC;";

                return await ExecuteServiceCatalogueQueryAsync(sql);
            }
            catch
            {
                return null;
            }
        }

        private async Task<Dictionary<string, object?>?> GetServiceCatalogueDetailAsync(long serviceId)
        {
            const string sql = @"
SELECT
      s.[serviceID]
    , s.[serviceCode]
    , COALESCE(NULLIF(LTRIM(RTRIM(s.[serviceName_A])), N''), s.[serviceName_E]) AS [serviceName_A]
    , s.[serviceName_E]
    , s.[serviceDesc]
        , s.[defaultPriorityID_FK]
    , s.[serviceActive]
    , s.[requiresLocation]
    , s.[allowsChildTickets]
    , s.[requiresQualityReview]
    , tc.[ticketClassName_A]
    , tc.[ticketClassName_E]
    , COALESCE(NULLIF(LTRIM(RTRIM(p.[priorityName_A])), N''), p.[priorityName_E]) AS [priorityName_A]
    , p.[priorityName_E]
    , activeRoute.[serviceRoutingRuleID] AS [activeRoutingRuleID]
    , activeRoute.[targetDSDID_FK] AS [activeTargetDSDID]
    , activeRoute.[queueDistributorID_FK] AS [queueDistributorID_FK]
    , activeRoute.[effectiveFrom] AS [routingEffectiveFrom]
    , routeDsd.[DepartmentName] AS [routingDepartmentName]
    , routeDsd.[DivisonName] AS [routingDivisionName]
    , routeDsd.[SectionName] AS [routingSectionName]
    , COALESCE(NULLIF(LTRIM(RTRIM(dist.[distributorName_A])), N''), dist.[distributorName_E]) AS [routingDistributorName]
    , defaultSla.[serviceSLAPolicyID] AS [slaPolicyID]
    , defaultSla.[priorityID_FK] AS [slaPriorityID_FK]
    , COALESCE(NULLIF(LTRIM(RTRIM(slaPriority.[priorityName_A])), N''), slaPriority.[priorityName_E]) AS [slaPriorityName]
    , defaultSla.[firstResponseTargetMinutes]
    , defaultSla.[assignmentTargetMinutes]
    , defaultSla.[operationalCompletionTargetMinutes]
    , defaultSla.[finalClosureTargetMinutes]
FROM [Tickets].[Service] s
LEFT JOIN [Tickets].[TicketClass] tc
    ON tc.[ticketClassID] = s.[ticketClassID_FK]
LEFT JOIN [Tickets].[Priority] p
    ON p.[priorityID] = s.[defaultPriorityID_FK]
OUTER APPLY
(
    SELECT TOP (1)
          rr.[serviceRoutingRuleID]
        , rr.[targetDSDID_FK]
        , rr.[queueDistributorID_FK]
        , rr.[effectiveFrom]
    FROM [Tickets].[ServiceRoutingRule] rr
    WHERE rr.[serviceID_FK] = s.[serviceID]
      AND rr.[serviceRoutingRuleActive] = 1
      AND rr.[effectiveFrom] <= GETDATE()
      AND (rr.[effectiveTo] IS NULL OR rr.[effectiveTo] > GETDATE())
    ORDER BY rr.[effectiveFrom] DESC, rr.[serviceRoutingRuleID] DESC
) activeRoute
LEFT JOIN dbo.[V_GetFullStructureForDSD] routeDsd
    ON routeDsd.[DSDID] = activeRoute.[targetDSDID_FK]
LEFT JOIN dbo.[Distributor] dist
    ON dist.[distributorID] = activeRoute.[queueDistributorID_FK]
   AND ISNULL(dist.[distributorActive], 0) = 1
OUTER APPLY
(
    SELECT TOP (1)
          sp.[serviceSLAPolicyID]
        , sp.[priorityID_FK]
        , sp.[firstResponseTargetMinutes]
        , sp.[assignmentTargetMinutes]
        , sp.[operationalCompletionTargetMinutes]
        , sp.[finalClosureTargetMinutes]
    FROM [Tickets].[ServiceSLAPolicy] sp
    WHERE sp.[serviceID_FK] = s.[serviceID]
      AND sp.[slaPolicyActive] = 1
      AND sp.[priorityID_FK] = s.[defaultPriorityID_FK]
    ORDER BY sp.[effectiveFrom] DESC, sp.[serviceSLAPolicyID] DESC
) defaultSla
LEFT JOIN [Tickets].[Priority] slaPriority
    ON slaPriority.[priorityID] = defaultSla.[priorityID_FK]
WHERE s.[serviceID] = @serviceID
  AND (s.[idaraID_FK] = @idaraID OR s.[idaraID_FK] IS NULL);";

            var table = await ExecuteServiceCatalogueQueryAsync(
                sql,
                new Dictionary<string, object?> { ["serviceID"] = serviceId });

            if (table.Rows.Count == 0)
                return null;

            var row = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
            foreach (DataColumn column in table.Columns)
                row[column.ColumnName] = table.Rows[0][column] == DBNull.Value ? null : table.Rows[0][column];

            row["serviceName_A"] = GetPreferredDisplayName(GetDictionaryValue(row, "serviceName_A"), GetDictionaryValue(row, "serviceName_E"));
            row["priorityName_A"] = GetPreferredDisplayName(GetDictionaryValue(row, "priorityName_A"), GetDictionaryValue(row, "priorityName_E"));
            row["slaPriorityName"] = GetPreferredDisplayName(GetDictionaryValue(row, "slaPriorityName"), GetDictionaryValue(row, "priorityName_E"));

            return row;
        }

        private async Task<List<Dictionary<string, object?>>> GetServiceCatalogueSlaPoliciesAsync(long serviceId)
        {
            const string sql = @"
SELECT
      sp.[serviceSLAPolicyID]
    , sp.[priorityID_FK]
    , COALESCE(NULLIF(LTRIM(RTRIM(p.[priorityName_A])), N''), p.[priorityName_E]) AS [priorityName_A]
    , sp.[firstResponseTargetMinutes]
    , sp.[assignmentTargetMinutes]
    , sp.[operationalCompletionTargetMinutes]
    , sp.[finalClosureTargetMinutes]
FROM [Tickets].[ServiceSLAPolicy] sp
LEFT JOIN [Tickets].[Priority] p
    ON p.[priorityID] = sp.[priorityID_FK]
WHERE sp.[serviceID_FK] = @serviceID
  AND sp.[slaPolicyActive] = 1
  AND (sp.[idaraID_FK] = @idaraID OR sp.[idaraID_FK] IS NULL)
ORDER BY sp.[priorityID_FK], sp.[serviceSLAPolicyID] DESC;";

            var table = await ExecuteServiceCatalogueQueryAsync(
                sql,
                new Dictionary<string, object?> { ["serviceID"] = serviceId });

            var result = new List<Dictionary<string, object?>>();
            foreach (DataRow dataRow in table.Rows)
            {
                var row = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
                foreach (DataColumn column in table.Columns)
                    row[column.ColumnName] = dataRow[column] == DBNull.Value ? null : dataRow[column];
                result.Add(row);
            }

            return result;
        }

        private async Task<List<OptionItem>> GetServiceCatalogueDsdOptionsAsync()
        {
            const string sql = @"
SELECT [DSDID], [DepartmentName], [DivisonName], [SectionName]
FROM dbo.[V_GetFullStructureForDSD]
WHERE [IdaraID] = @idaraID
ORDER BY [DepartmentName], [DivisonName], [SectionName];";

            var table = await ExecuteServiceCatalogueQueryAsync(sql);
            var options = new List<OptionItem>
            {
                new() { Value = string.Empty, Text = "اختر الجهة المستهدفة" }
            };

            foreach (DataRow row in table.Rows)
            {
                var value = row["DSDID"]?.ToString();
                if (string.IsNullOrWhiteSpace(value))
                    continue;

                var parts = new[]
                {
                    row["DepartmentName"]?.ToString()?.Trim(),
                    row["DivisonName"]?.ToString()?.Trim(),
                    row["SectionName"]?.ToString()?.Trim()
                }
                .Where(part => !string.IsNullOrWhiteSpace(part));

                options.Add(new OptionItem
                {
                    Value = value,
                    Text = string.Join(" / ", parts)
                });
            }

            return options;
        }

        private async Task<List<OptionItem>> GetServiceCatalogueDistributorOptionsAsync()
        {
            const string sql = @"
SELECT
      d.[distributorID]
    , COALESCE(NULLIF(LTRIM(RTRIM(d.[distributorName_A])), N''), d.[distributorName_E]) AS [distributorName]
    , dsd.[DepartmentName]
    , dsd.[DivisonName]
    , dsd.[SectionName]
FROM dbo.[Distributor] d
LEFT JOIN dbo.[V_GetFullStructureForDSD] dsd
    ON dsd.[DSDID] = d.[DSDID_FK]
WHERE ISNULL(d.[distributorActive], 0) = 1
  AND (dsd.[IdaraID] = @idaraID OR dsd.[IdaraID] IS NULL)
ORDER BY [distributorName];";

            var table = await ExecuteServiceCatalogueQueryAsync(sql);
            var options = new List<OptionItem>
            {
                new() { Value = string.Empty, Text = "بدون موزع محدد" }
            };

            foreach (DataRow row in table.Rows)
            {
                var value = row["distributorID"]?.ToString();
                var distributorName = row["distributorName"]?.ToString()?.Trim();
                if (string.IsNullOrWhiteSpace(value) || string.IsNullOrWhiteSpace(distributorName))
                    continue;

                var locationBits = new[]
                {
                    row["DepartmentName"]?.ToString()?.Trim(),
                    row["DivisonName"]?.ToString()?.Trim(),
                    row["SectionName"]?.ToString()?.Trim()
                }
                .Where(bit => !string.IsNullOrWhiteSpace(bit));

                var location = string.Join(" / ", locationBits);
                options.Add(new OptionItem
                {
                    Value = value,
                    Text = string.IsNullOrWhiteSpace(location) ? distributorName : $"{distributorName} - {location}"
                });
            }

            return options;
        }

        private async Task<DataTable> ExecuteServiceCatalogueQueryAsync(
            string sql,
            IDictionary<string, object?>? parameters = null)
        {
            var table = new DataTable();

            using var connection = new SqlConnection(GetDefaultConnectionString());
            await connection.OpenAsync();

            using var command = new SqlCommand(sql, connection);
            command.Parameters.AddWithValue("@idaraID", TryGetCurrentIdaraId(out var idaraId) ? idaraId : DBNull.Value);

            if (parameters != null)
            {
                foreach (var parameter in parameters)
                {
                    var name = parameter.Key.StartsWith("@", StringComparison.Ordinal)
                        ? parameter.Key
                        : "@" + parameter.Key;
                    command.Parameters.AddWithValue(name, parameter.Value ?? DBNull.Value);
                }
            }

            using var reader = await command.ExecuteReaderAsync();
            table.Load(reader);
            return table;
        }

        private async Task<(bool Success, string Message)> ExecuteServiceCatalogueStoredProcedureAsync(
            string action,
            IDictionary<string, object?> parameters)
        {
            using var connection = new SqlConnection(GetDefaultConnectionString());
            await connection.OpenAsync();

            using var command = new SqlCommand("[Tickets].[ServiceSP]", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@Action", action);

            foreach (var parameter in parameters)
            {
                var name = parameter.Key.StartsWith("@", StringComparison.Ordinal)
                    ? parameter.Key
                    : "@" + parameter.Key;
                command.Parameters.AddWithValue(name, parameter.Value ?? DBNull.Value);
            }

            using var reader = await command.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                bool success = IsTruthy(reader["IsSuccessful"]);
                string message = reader["Message_"]?.ToString()?.Trim()
                    ?? (success ? "تمت العملية بنجاح" : "فشلت العملية");
                return (success, message);
            }

            return (true, "تمت العملية بنجاح");
        }

        private string BuildServiceCatalogueDetailHtml(Dictionary<string, object?> service)
        {
            string serviceCode = Encode(GetDictionaryValue(service, "serviceCode"));
            string serviceName = Encode(GetPreferredDisplayName(GetDictionaryValue(service, "serviceName_A"), GetDictionaryValue(service, "serviceName_E")));
            string routingDepartment = Encode(NormalizeDisplayValue(GetDictionaryValue(service, "routingDepartmentName"), "-") ?? "-");
            string routingDivision = Encode(NormalizeDisplayValue(GetDictionaryValue(service, "routingDivisionName"), "-") ?? "-");
            string routingSection = Encode(NormalizeDisplayValue(GetDictionaryValue(service, "routingSectionName"), "-") ?? "-");
            string slaPriority = Encode(GetPreferredDisplayName(GetDictionaryValue(service, "slaPriorityName"), GetDictionaryValue(service, "priorityName_A")));
            string status = IsTruthy(GetDictionaryValue(service, "serviceActive")) ? "نشطة" : "غير نشطة";

                        return $$"""
<div class="space-y-5 text-right">
    <div class="pb-4 space-y-1 border-b border-slate-200">
        <div class="font-mono text-sm text-slate-400">{{serviceCode}}</div>
        <div class="text-lg font-semibold text-slate-900">{{serviceName}}</div>
    </div>

    <section class="p-4 bg-white border shadow-sm rounded-xl border-slate-200">
        <div class="mb-3 text-xs font-semibold tracking-wide uppercase text-slate-500">قاعدة التوجيه الافتراضية</div>
        <div class="grid grid-cols-1 gap-3 text-sm text-slate-700 md:grid-cols-3">
            <div>
                <div class="text-[10px] uppercase text-slate-400">القسم</div>
                <div class="font-medium">{{routingDepartment}}</div>
            </div>
            <div>
                <div class="text-[10px] uppercase text-slate-400">الشعبة</div>
                <div class="font-medium">{{routingDivision}}</div>
            </div>
            <div>
                <div class="text-[10px] uppercase text-slate-400">القسم الفرعي</div>
                <div class="font-medium">{{routingSection}}</div>
            </div>
        </div>
    </section>

    <section class="p-4 bg-white border shadow-sm rounded-xl border-slate-200">
        <div class="mb-3 text-xs font-semibold tracking-wide uppercase text-slate-500">SLA الافتراضي ({{slaPriority}})</div>
        <div class="grid grid-cols-1 gap-3 text-sm md:grid-cols-2">
            {{BuildSlaCardHtml("الاستجابة الأولى", "blue", GetDictionaryValue(service, "firstResponseTargetMinutes"))}}
            {{BuildSlaCardHtml("الإسناد", "indigo", GetDictionaryValue(service, "assignmentTargetMinutes"))}}
            {{BuildSlaCardHtml("الإنجاز التشغيلي", "yellow", GetDictionaryValue(service, "operationalCompletionTargetMinutes"))}}
            {{BuildSlaCardHtml("الإغلاق النهائي", "green", GetDictionaryValue(service, "finalClosureTargetMinutes"))}}
        </div>
    </section>

    <div class="flex items-center justify-between text-xs text-slate-400">
        <span>الحالة: {{Encode(status)}}</span>
        <span>ID: {{Encode(GetDictionaryValue(service, "serviceID"))}}</span>
    </div>
</div>
""";
        }

        private string BuildServiceCatalogueRoutingFormHtml(
            Dictionary<string, object?> service,
            List<OptionItem> dsdOptions,
            List<OptionItem> distributorOptions)
        {
            string selectedDsdId = Convert.ToString(GetDictionaryValue(service, "activeTargetDSDID"), CultureInfo.InvariantCulture) ?? string.Empty;
            string serviceCode = Encode(GetDictionaryValue(service, "serviceCode"));
            string serviceName = Encode(GetPreferredDisplayName(GetDictionaryValue(service, "serviceName_A"), GetDictionaryValue(service, "serviceName_E")));
            string currentRoute = Encode(NormalizeDisplayValue(GetDictionaryValue(service, "routingDepartmentName"), "-") ?? "-");
            string currentDivision = Encode(NormalizeDisplayValue(GetDictionaryValue(service, "routingDivisionName"), "-") ?? "-");
            string currentSection = Encode(NormalizeDisplayValue(GetDictionaryValue(service, "routingSectionName"), "-") ?? "-");
            string currentDistributor = Encode(NormalizeDisplayValue(GetDictionaryValue(service, "routingDistributorName"), "غير محدد") ?? "غير محدد");
            string effectiveFromValue = DateTime.Now.ToString("yyyy-MM-ddTHH:mm", CultureInfo.InvariantCulture);

                        return $$"""
<div class="space-y-4 text-right">
    <div class="p-4 border rounded-xl border-slate-200 bg-slate-50">
        <div class="font-mono text-xs text-slate-400">{{serviceCode}}</div>
        <div class="mt-1 text-base font-semibold text-slate-900">{{serviceName}}</div>
        <div class="grid grid-cols-1 gap-3 mt-3 text-sm text-slate-600 md:grid-cols-2">
            <div>
                <div class="text-[10px] uppercase text-slate-400">المسار الحالي</div>
                <div class="font-medium">{{currentRoute}}</div>
                <div class="font-medium">{{currentDivision}}</div>
                <div class="font-medium">{{currentSection}}</div>
            </div>
            <div>
                <div class="text-[10px] uppercase text-slate-400">الموزع الحالي</div>
                <div class="font-medium">{{currentDistributor}}</div>
            </div>
        </div>
        <div class="mt-3 text-xs text-amber-700">سيتم إغلاق أي توجيه نشط حاليًا ثم إنشاء توجيه جديد بنفس الخدمة.</div>
    </div>

    <form method="post" action="/{{ControllerName}}/ServiceCatalogueSaveRoutingRule" class="space-y-4">
        <input type="hidden" name="serviceID" value="{{Encode(GetDictionaryValue(service, "serviceID"))}}">

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
            <div>
                <label class="block mb-1 text-sm font-medium text-slate-700">الجهة المستهدفة</label>
                <select name="targetDSDID_FK" class="w-full px-3 py-2 text-sm border rounded-lg border-slate-300 focus:border-sky-500 focus:outline-none" required>
                    {{BuildSelectOptionsHtml(dsdOptions, selectedDsdId)}}
                </select>
            </div>

            <div>
                <label class="block mb-1 text-sm font-medium text-slate-700">الموزع</label>
                <select name="queueDistributorID_FK" class="w-full px-3 py-2 text-sm border rounded-lg border-slate-300 focus:border-sky-500 focus:outline-none">
                    {{BuildSelectOptionsHtml(distributorOptions, Convert.ToString(GetDictionaryValue(service, "queueDistributorID_FK"), CultureInfo.InvariantCulture))}}
                </select>
            </div>
        </div>

        <div>
            <label class="block mb-1 text-sm font-medium text-slate-700">سبب التغيير</label>
            <textarea name="changeReason" rows="3" class="w-full px-3 py-2 text-sm border rounded-lg border-slate-300 focus:border-sky-500 focus:outline-none" placeholder="اشرح سبب تحديث التوجيه"></textarea>
        </div>

        <div>
            <label class="block mb-1 text-sm font-medium text-slate-700">ساري من</label>
            <input type="datetime-local" name="effectiveFrom" value="{{effectiveFromValue}}" class="w-full px-3 py-2 text-sm border rounded-lg border-slate-300 focus:border-sky-500 focus:outline-none">
        </div>

        <div class="flex items-center justify-end gap-2 pt-3 border-t border-slate-200">
            <button type="button" class="px-4 py-2 text-sm border rounded-lg border-slate-300 text-slate-600" onclick="this.closest('.sf-modal').__x.$data.closeModal();">إلغاء</button>
            <button type="submit" class="px-4 py-2 text-sm font-medium text-white rounded-lg bg-amber-500 hover:bg-amber-600">حفظ التوجيه</button>
        </div>
    </form>
</div>
""";
        }

        private string BuildServiceCatalogueSlaFormHtml(
            Dictionary<string, object?> service,
            List<OptionItem> priorityOptions,
            List<Dictionary<string, object?>> policies)
        {
            string serviceCode = Encode(GetDictionaryValue(service, "serviceCode"));
            string serviceName = Encode(GetPreferredDisplayName(GetDictionaryValue(service, "serviceName_A"), GetDictionaryValue(service, "serviceName_E")));
            string defaultPriorityId = Convert.ToString(GetDictionaryValue(service, "defaultPriorityID_FK"), CultureInfo.InvariantCulture) ?? string.Empty;

            var policiesHtml = new StringBuilder();
            if (policies.Count == 0)
            {
                policiesHtml.Append("<div class=\"rounded-lg border border-dashed border-slate-300 px-4 py-3 text-sm text-slate-500\">لا توجد سياسات SLA مسجلة لهذه الخدمة بعد.</div>");
            }
            else
            {
                foreach (var policy in policies)
                {
                                        policiesHtml.Append($$"""
<div class="p-3 border rounded-lg border-slate-200 bg-slate-50">
    <div class="mb-2 text-sm font-semibold text-slate-700">{{Encode(GetDictionaryValue(policy, "priorityName_A"))}}</div>
    <div class="grid grid-cols-2 gap-2 text-xs text-slate-600 md:grid-cols-4">
        <div>الاستجابة الأولى: <span class="font-semibold">{{Encode(FormatSlaDuration(GetDictionaryValue(policy, "firstResponseTargetMinutes")))}}</span></div>
        <div>الإسناد: <span class="font-semibold">{{Encode(FormatSlaDuration(GetDictionaryValue(policy, "assignmentTargetMinutes")))}}</span></div>
        <div>الإنجاز: <span class="font-semibold">{{Encode(FormatSlaDuration(GetDictionaryValue(policy, "operationalCompletionTargetMinutes")))}}</span></div>
        <div>الإغلاق: <span class="font-semibold">{{Encode(FormatSlaDuration(GetDictionaryValue(policy, "finalClosureTargetMinutes")))}}</span></div>
    </div>
</div>
""");
                }
            }

                        return $$"""
<div class="space-y-4 text-right">
    <div class="p-4 border rounded-xl border-slate-200 bg-slate-50">
        <div class="font-mono text-xs text-slate-400">{{serviceCode}}</div>
        <div class="mt-1 text-base font-semibold text-slate-900">{{serviceName}}</div>
        <div class="mt-2 text-xs text-slate-500">يمكنك إدارة سياسات SLA لكل أولوية على حدة. الحفظ يعالج الإدخال والتحديث عبر نفس الإجراء.</div>
    </div>

    <div class="space-y-2">
        <div class="text-xs font-semibold tracking-wide uppercase text-slate-500">السياسات الحالية</div>
        {{policiesHtml}}
    </div>

    <form method="post" action="/{{ControllerName}}/ServiceCatalogueSaveSlaPolicy" class="p-4 space-y-4 bg-white border shadow-sm rounded-xl border-slate-200">
        <input type="hidden" name="serviceID" value="{{Encode(GetDictionaryValue(service, "serviceID"))}}">

        <div>
            <label class="block mb-1 text-sm font-medium text-slate-700">الأولوية</label>
            <select name="priorityID_FK" class="w-full px-3 py-2 text-sm border rounded-lg border-slate-300 focus:border-sky-500 focus:outline-none" required>
                {{BuildSelectOptionsHtml(priorityOptions, defaultPriorityId)}}
            </select>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
            <div>
                <label class="block mb-1 text-sm font-medium text-slate-700">الاستجابة الأولى (بالدقائق)</label>
                <input type="number" name="firstResponseTargetMinutes" min="0" class="w-full px-3 py-2 text-sm border rounded-lg border-slate-300 focus:border-sky-500 focus:outline-none">
            </div>
            <div>
                <label class="block mb-1 text-sm font-medium text-slate-700">الإسناد (بالدقائق)</label>
                <input type="number" name="assignmentTargetMinutes" min="0" class="w-full px-3 py-2 text-sm border rounded-lg border-slate-300 focus:border-sky-500 focus:outline-none">
            </div>
            <div>
                <label class="block mb-1 text-sm font-medium text-slate-700">الإنجاز التشغيلي (بالدقائق)</label>
                <input type="number" name="operationalCompletionTargetMinutes" min="0" class="w-full px-3 py-2 text-sm border rounded-lg border-slate-300 focus:border-sky-500 focus:outline-none">
            </div>
            <div>
                <label class="block mb-1 text-sm font-medium text-slate-700">الإغلاق النهائي (بالدقائق)</label>
                <input type="number" name="finalClosureTargetMinutes" min="0" class="w-full px-3 py-2 text-sm border rounded-lg border-slate-300 focus:border-sky-500 focus:outline-none">
            </div>
        </div>

        <div class="flex items-center justify-end gap-2 pt-3 border-t border-slate-200">
            <button type="button" class="px-4 py-2 text-sm border rounded-lg border-slate-300 text-slate-600" onclick="this.closest('.sf-modal').__x.$data.closeModal();">إلغاء</button>
            <button type="submit" class="px-4 py-2 text-sm font-medium text-white rounded-lg bg-slate-900 hover:bg-slate-800">حفظ SLA</button>
        </div>
    </form>
</div>
""";
        }

        private static string BuildSlaCardHtml(string label, string color, object? minutes)
        {
            string safeLabel = HtmlEncoder.Default.Encode(label);
            string safeValue = HtmlEncoder.Default.Encode(FormatSlaDuration(minutes));

                        return $$"""
<div class="rounded-lg bg-{{color}}-50 p-3 text-center">
    <div class="text-[10px] font-semibold uppercase text-{{color}}-600">{{safeLabel}}</div>
    <div class="text-lg font-bold text-{{color}}-800">{{safeValue}}</div>
</div>
""";
        }

        private static string BuildSelectOptionsHtml(IEnumerable<OptionItem> options, string? selectedValue)
        {
            var builder = new StringBuilder();

            foreach (var option in options)
            {
                string value = option.Value ?? string.Empty;
                bool selected = string.Equals(value, selectedValue ?? string.Empty, StringComparison.OrdinalIgnoreCase);
                builder.Append("<option value=\"")
                    .Append(HtmlEncoder.Default.Encode(value))
                    .Append("\"");

                if (selected)
                    builder.Append(" selected");

                builder.Append(">")
                    .Append(HtmlEncoder.Default.Encode(option.Text ?? value))
                    .Append("</option>");
            }

            return builder.ToString();
        }

        private static string BuildModalErrorHtml(string message)
        {
                        return $$"""
<div class="p-4 text-sm text-right text-red-700 border border-red-200 rounded-xl bg-red-50">
    <div class="font-semibold">تعذر تحميل المحتوى</div>
    <div class="mt-1">{{HtmlEncoder.Default.Encode(message)}}</div>
</div>
""";
        }

        private static bool IsFailedServiceCatalogueDataLoad(DataTable? table)
        {
            if (table == null || table.Columns.Count == 0 || table.Rows.Count == 0)
                return false;

            return table.Columns.Contains("IsSuccessful")
                && table.Columns.Contains("Message_")
                && !table.Columns.Contains("serviceName_A");
        }

        private static bool HasServiceCatalogueProjection(DataTable? table)
        {
            if (table == null)
                return false;

            return table.Columns.Contains("serviceCode")
                && table.Columns.Contains("serviceName_A")
                && table.Columns.Contains("priorityName_A")
                && table.Columns.Contains("departmentName")
                && table.Columns.Contains("divisionSectionName");
        }

        private static object? GetDictionaryValue(Dictionary<string, object?> dictionary, string key)
        {
            return dictionary.TryGetValue(key, out var value) ? value : null;
        }

        private static string GetPreferredDisplayName(object? arabicValue, object? englishValue)
        {
            string? arabic = NormalizeNullableString(arabicValue);
            if (!string.IsNullOrWhiteSpace(arabic))
                return arabic;

            string? english = NormalizeNullableString(englishValue);
            return string.IsNullOrWhiteSpace(english) ? "-" : english;
        }

        private static string? NormalizeDisplayValue(object? primaryValue, string? fallback)
        {
            string? value = NormalizeNullableString(primaryValue);
            return string.IsNullOrWhiteSpace(value) ? fallback : value;
        }

        private static string? NormalizeNullableString(object? value)
        {
            if (value == null || value == DBNull.Value)
                return null;

            string? text = Convert.ToString(value, CultureInfo.InvariantCulture)?.Trim();
            return string.IsNullOrWhiteSpace(text) ? null : text;
        }

        private static string Encode(object? value)
        {
            return HtmlEncoder.Default.Encode(Convert.ToString(value, CultureInfo.InvariantCulture) ?? string.Empty);
        }

        private static bool IsTruthy(object? value)
        {
            if (value == null || value == DBNull.Value)
                return false;

            return value switch
            {
                bool boolean => boolean,
                byte numericByte => numericByte != 0,
                short numericShort => numericShort != 0,
                int numericInt => numericInt != 0,
                long numericLong => numericLong != 0,
                string text when bool.TryParse(text, out var parsedBool) => parsedBool,
                string text when long.TryParse(text, out var parsedLong) => parsedLong != 0,
                _ => false
            };
        }

        private static long? TryGetInt64(object? value)
        {
            if (value == null || value == DBNull.Value)
                return null;

            return long.TryParse(Convert.ToString(value, CultureInfo.InvariantCulture), out var parsed)
                ? parsed
                : null;
        }

        private bool TryGetCurrentIdaraId(out int idaraId)
        {
            return int.TryParse(IdaraId, NumberStyles.Integer, CultureInfo.InvariantCulture, out idaraId);
        }

        private async Task<bool> HasMenuPermissionAsync(string pageName, string permissionType)
        {
            if (string.IsNullOrWhiteSpace(pageName) || string.IsNullOrWhiteSpace(permissionType))
                return false;

            var currentUserId = TryGetCurrentUserId();
            if (!currentUserId.HasValue)
                return false;

            const string sql = @"
SELECT TOP (1) 1
FROM dbo.[V_GetListUserPermission]
WHERE [userID] = @userID
  AND [menuName_E] = @pageName
  AND [permissionTypeName_E] = @permissionType;";

            using var connection = new SqlConnection(GetDefaultConnectionString());
            await connection.OpenAsync();

            using var command = new SqlCommand(sql, connection);
            command.Parameters.AddWithValue("@userID", currentUserId.Value);
            command.Parameters.AddWithValue("@pageName", pageName);
            command.Parameters.AddWithValue("@permissionType", permissionType);

            var result = await command.ExecuteScalarAsync();
            return result != null && result != DBNull.Value;
        }

        private int? TryGetCurrentUserId()
        {
            return int.TryParse(usersId, NumberStyles.Integer, CultureInfo.InvariantCulture, out var parsed)
                ? parsed
                : null;
        }

        private static string FormatSlaDuration(object? minutesValue)
        {
            if (!int.TryParse(Convert.ToString(minutesValue, CultureInfo.InvariantCulture), out var minutes) || minutes < 0)
                return "—";

            if (minutes < 60)
                return $"{minutes}m";

            var duration = TimeSpan.FromMinutes(minutes);
            if (duration.Minutes == 0)
                return $"{(int)duration.TotalHours}h";

            return $"{(int)duration.TotalHours}h {duration.Minutes}m";
        }

        public sealed class ServiceCatalogueServiceFormModel
        {
            public long serviceID { get; set; }
            public string? serviceCode { get; set; }
            public string? serviceName_A { get; set; }
            public string? serviceName_E { get; set; }
            public string? serviceDesc { get; set; }
            public int? ticketClassID_FK { get; set; }
            public int? defaultPriorityID_FK { get; set; }
            public bool requiresLocation { get; set; }
            public bool allowsChildTickets { get; set; }
            public bool requiresQualityReview { get; set; }
        }

        public sealed class ServiceCatalogueDeleteFormModel
        {
            public long serviceID { get; set; }
        }

        public sealed class ServiceCatalogueRoutingFormModel
        {
            public long serviceID { get; set; }
            public int? targetDSDID_FK { get; set; }
            public long? queueDistributorID_FK { get; set; }
            public string? changeReason { get; set; }
            public DateTime? effectiveFrom { get; set; }
        }

        public sealed class ServiceCatalogueSlaFormModel
        {
            public long serviceID { get; set; }
            public int? priorityID_FK { get; set; }
            public int? firstResponseTargetMinutes { get; set; }
            public int? assignmentTargetMinutes { get; set; }
            public int? operationalCompletionTargetMinutes { get; set; }
            public int? finalClosureTargetMinutes { get; set; }
        }
    }
}