using Microsoft.AspNetCore.Mvc;
using SmartFoundation.UI.ViewModels.SmartForm;
using SmartFoundation.UI.ViewModels.SmartPage;
using SmartFoundation.UI.ViewModels.SmartTable;
using System.Data;
using System.Linq;
using System.Text.Json;

namespace SmartFoundation.Mvc.Controllers.Tickets
{
    public partial class TicketController : Controller
    {
        public async Task<IActionResult> TicketAdmin()
        {
            if (!InitPageContext(out var redirect))
                return redirect!;

            if (string.IsNullOrWhiteSpace(usersId))
                return RedirectToAction("Index", "Login", new { logout = 4 });

            ControllerName = nameof(TicketController).Replace("Controller", "");
            PageName = "TicketAdmin";

            DataSet dsServices = await _mastersServies.GetDataLoadDataSetAsync(
                "ServiceCatalogueList", IdaraId, usersId, HostName, null, null
            );
            SplitDataSet(dsServices);

            if (permissionTable is null || permissionTable.Rows.Count == 0)
            {
                TempData["Error"] = "تم رصد دخول غير مصرح به انت لاتملك صلاحية للوصول الى هذه الصفحة";
                return RedirectToAction("Index", "Home");
            }

            bool canInsertService = false, canUpdateService = false, canDeleteService = false;
            bool canInsertClass = false, canUpdateClass = false, canDeleteClass = false;
            bool canInsertPriority = false, canUpdatePriority = false, canDeletePriority = false;
            bool canInsertStatus = false, canUpdateStatus = false, canDeleteStatus = false;
            bool canInsertPauseReason = false, canUpdatePauseReason = false, canDeletePauseReason = false;
            bool canInsertArbReason = false, canUpdateArbReason = false, canDeleteArbReason = false;
            bool canInsertQRR = false, canUpdateQRR = false, canDeleteQRR = false;
            bool canManageRoutingRules = false, canManageSLAPolicies = false, canApproveServiceSuggestion = false;

            foreach (DataRow row in permissionTable.Rows)
            {
                var perm = row["permissionTypeName_E"]?.ToString()?.Trim().ToUpper();
                if (perm == "INSERTSERVICE") canInsertService = true;
                if (perm == "UPDATESERVICE") canUpdateService = true;
                if (perm == "DELETESERVICE") canDeleteService = true;
                if (perm == "INSERTTICKETCLASS") canInsertClass = true;
                if (perm == "UPDATETICKETCLASS") canUpdateClass = true;
                if (perm == "DELETETICKETCLASS") canDeleteClass = true;
                if (perm == "INSERTPRIORITY") canInsertPriority = true;
                if (perm == "UPDATEPRIORITY") canUpdatePriority = true;
                if (perm == "DELETEPRIORITY") canDeletePriority = true;
                if (perm == "INSERTTICKETSTATUS") canInsertStatus = true;
                if (perm == "UPDATETICKETSTATUS") canUpdateStatus = true;
                if (perm == "DELETETICKETSTATUS") canDeleteStatus = true;
                if (perm == "INSERTPAUSEREASON") canInsertPauseReason = true;
                if (perm == "UPDATEPAUSEREASON") canUpdatePauseReason = true;
                if (perm == "DELETEPAUSEREASON") canDeletePauseReason = true;
                if (perm == "INSERTARBITRATIONREASON") canInsertArbReason = true;
                if (perm == "UPDATEARBITRATIONREASON") canUpdateArbReason = true;
                if (perm == "DELETEARBITRATIONREASON") canDeleteArbReason = true;
                if (perm == "INSERTQUALITYREVIEWRESULT") canInsertQRR = true;
                if (perm == "UPDATEQUALITYREVIEWRESULT") canUpdateQRR = true;
                if (perm == "DELETEQUALITYREVIEWRESULT") canDeleteQRR = true;
                if (perm == "MANAGEROUTINGRULES") canManageRoutingRules = true;
                if (perm == "MANAGESLAPOLICIES") canManageSLAPolicies = true;
                if (perm == "APPROVESERVICESUGGESTION") canApproveServiceSuggestion = true;
            }

            List<OptionItem> ticketClassOptions = await GetDDLAsync("ticketClassName_A", "ticketClassID", "2", "TicketClassDDL");
            List<OptionItem> priorityOptions = await GetDDLAsync("priorityName_A", "priorityID", "2", "PriorityDDL");

            var tabGroupKey = "ticket-admin";
            const string crudPageName = "Tickets";
            string currentUrl = $"/{ControllerName}/TicketAdmin";

            SmartTableDsModel BuildLookupTab(DataTable? dt, string rowIdCol, string tabKey, string tabLabel, string tabIcon, int tabOrder, bool isDefault,
                string insertAction, string updateAction, string deleteAction,
                bool canInsert, bool canUpdate, bool canDelete,
                Dictionary<string, string> headerMap, HashSet<string> hiddenCols,
                List<FieldConfig> insertVisible, List<FieldConfig> updateVisible)
            {
                var columns = new List<TableColumn>();
                var rows = new List<Dictionary<string, object?>>();

                if (dt != null && dt.Columns.Count > 0)
                {
                    foreach (DataColumn col in dt.Columns)
                    {
                        string colType = GetColType(col.DataType);
                        bool isHidden = hiddenCols.Contains(col.ColumnName);
                        string label = headerMap.TryGetValue(col.ColumnName, out var lbl) ? lbl : col.ColumnName;

                        columns.Add(new TableColumn
                        {
                            Field = col.ColumnName,
                            Label = label,
                            Type = colType,
                            Sortable = true,
                            Visible = !isHidden
                        });
                    }

                    foreach (DataRow dr in dt.Rows)
                    {
                        var dict = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
                        foreach (DataColumn col in dt.Columns)
                            dict[col.ColumnName] = dr[col] == DBNull.Value ? null : dr[col];
                        dict["p01"] = dict.ContainsKey(rowIdCol) ? dict[rowIdCol] : null;
                        rows.Add(dict);
                    }
                }

                var toolbar = new TableToolbarConfig
                {
                    ShowRefresh = true,
                    ShowColumns = true,
                    ShowExportExcel = true,
                    ShowAdd = canInsert,
                    ShowEdit = canUpdate,
                    ShowDelete = canDelete
                };

                if (canInsert)
                {
                    var addFields = BuildCrudFields(crudPageName, insertAction, currentUrl, insertVisible);
                    toolbar.Add = new TableAction
                    {
                        Label = "إضافة",
                        Icon = "fa fa-plus",
                        Color = "success",
                        OpenModal = true,
                        ModalTitle = $"إضافة {tabLabel}",
                        ModalMessage = "ملاحظة: جميع التعديلات مرصودة",
                        ModalMessageIcon = "fa-solid fa-circle-info",
                        ModalMessageClass = "bg-sky-100 text-sky-700",
                        OpenForm = new FormConfig
                        {
                            FormId = $"{tabKey}InsertForm",
                            Title = $"إضافة {tabLabel} جديد",
                            Method = "post",
                            ActionUrl = "/crud/insert",
                            Fields = addFields,
                            Buttons = new List<FormButtonConfig>
                            {
                                new() { Text = "حفظ", Type = "submit", Color = "success", Icon = "fa fa-check" },
                                new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" }
                            }
                        }
                    };
                }

                if (canUpdate)
                {
                    var editFields = BuildCrudFields(crudPageName, updateAction, currentUrl, updateVisible, hasP01: true);
                    toolbar.Edit = new TableAction
                    {
                        Label = "تعديل",
                        Icon = "fa fa-pen-to-square",
                        Color = "info",
                        IsEdit = true,
                        RequireSelection = true,
                        MinSelection = 1,
                        MaxSelection = 1,
                        OpenModal = true,
                        ModalTitle = $"تعديل {tabLabel}",
                        OpenForm = new FormConfig
                        {
                            FormId = $"{tabKey}EditForm",
                            Title = $"تعديل {tabLabel}",
                            Method = "post",
                            ActionUrl = "/crud/update",
                            Fields = editFields,
                            Buttons = new List<FormButtonConfig>
                            {
                                new() { Text = "حفظ التعديلات", Type = "submit", Color = "info", Icon = "fa fa-check" },
                                new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" }
                            }
                        }
                    };
                }

                if (canDelete)
                {
                    var deleteFields = BuildCrudFields(crudPageName, deleteAction, currentUrl,
                        new List<FieldConfig> { new() { Name = "p01", Type = "hidden" } },
                        hasP01: true, isDelete: true);

                    toolbar.Delete = new TableAction
                    {
                        Label = "حذف",
                        Icon = "fa fa-trash",
                        Color = "danger",
                        IsEdit = true,
                        RequireSelection = true,
                        MinSelection = 1,
                        MaxSelection = 1,
                        OpenModal = true,
                        ModalTitle = "تحذير",
                        ModalMessage = $"هل أنت متأكد من حذف هذا الـ{tabLabel}؟",
                        ModalMessageIcon = "fa fa-exclamation-triangle text-red-600",
                        ModalMessageClass = "bg-red-50 text-red-700",
                        OpenForm = new FormConfig
                        {
                            FormId = $"{tabKey}DeleteForm",
                            Title = $"تأكيد حذف {tabLabel}",
                            Method = "post",
                            ActionUrl = "/crud/delete",
                            Buttons = new List<FormButtonConfig>
                            {
                                new() { Text = "حذف", Type = "submit", Color = "danger", Icon = "fa fa-trash" },
                                new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" }
                            },
                            Fields = deleteFields
                        }
                    };
                }

                return new SmartTableDsModel
                {
                    PageTitle = tabLabel,
                    PanelTitle = tabLabel,
                    Columns = columns,
                    Rows = rows,
                    RowIdField = "p01",
                    PageSize = 10,
                    PageSizes = new List<int> { 10, 25, 50, 100 },
                    Searchable = true,
                    AllowExport = true,
                    ShowPageSizeSelector = true,
                    EnableCellCopy = true,
                    ShowColumnVisibility = true,
                    QuickSearchFields = columns.Where(c => c.Visible).Select(c => c.Field).Take(4).ToList(),
                    Toolbar = toolbar,
                    RenderMode = SmartTableRenderMode.Tab,
                    RenderAsTab = true,
                    TabGroupKey = tabGroupKey,
                    TabKey = tabKey,
                    TabLabel = tabLabel,
                    TabIcon = tabIcon,
                    TabDefaultActive = isDefault,
                    ShowTabCount = true,
                    TabOrder = tabOrder,
                    ShowToolbar = true,
                    EnablePagination = true
                };
            }

            var statusTask = _mastersServies.GetDataLoadDataSetAsync("StatusDDL", IdaraId, usersId, HostName);
            var pauseReasonTask = _mastersServies.GetDataLoadDataSetAsync("PauseReasonDDL", IdaraId, usersId, HostName);
            var arbReasonTask = _mastersServies.GetDataLoadDataSetAsync("ArbitrationReasonDDL", IdaraId, usersId, HostName);
            var qrrTask = _mastersServies.GetDataLoadDataSetAsync("QualityReviewResultDDL", IdaraId, usersId, HostName);
            var classTask = _mastersServies.GetDataLoadDataSetAsync("TicketClassDDL", IdaraId, usersId, HostName);
            var priorityTask = _mastersServies.GetDataLoadDataSetAsync("PriorityDDL", IdaraId, usersId, HostName);

            await Task.WhenAll(statusTask, pauseReasonTask, arbReasonTask, qrrTask, classTask, priorityTask);

            var dsStatus = statusTask.Result;
            DataTable? dtStatus = (dsStatus?.Tables?.Count ?? 0) > 1 ? dsStatus!.Tables[1] : null;

            var dsPauseReason = pauseReasonTask.Result;
            DataTable? dtPauseReason = (dsPauseReason?.Tables?.Count ?? 0) > 1 ? dsPauseReason!.Tables[1] : null;

            var dsArbReason = arbReasonTask.Result;
            DataTable? dtArbReason = (dsArbReason?.Tables?.Count ?? 0) > 1 ? dsArbReason!.Tables[1] : null;

            var dsQRR = qrrTask.Result;
            DataTable? dtQRR = (dsQRR?.Tables?.Count ?? 0) > 1 ? dsQRR!.Tables[1] : null;

            var dsClass = classTask.Result;
            DataTable? dtClass = (dsClass?.Tables?.Count ?? 0) > 1 ? dsClass!.Tables[1] : null;

            var dsPriority = priorityTask.Result;
            DataTable? dtPriority = (dsPriority?.Tables?.Count ?? 0) > 1 ? dsPriority!.Tables[1] : null;

            var serviceHeaderMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                ["serviceID"] = "رقم الخدمة",
                ["serviceCode"] = "كود الخدمة",
                ["serviceName_A"] = "اسم الخدمة",
                ["serviceName_E"] = "اسم الخدمة (إنجليزي)",
                ["serviceDesc"] = "الوصف",
                ["idaraID_FK"] = "الإدارة",
                ["ticketClassID_FK"] = "فئة التذكرة",
                ["ticketClassName_A"] = "فئة التذكرة",
                ["ticketClassName_E"] = "فئة التذكرة",
                ["defaultPriorityID_FK"] = "الأولوية الافتراضية",
                ["priorityName_A"] = "الأولوية",
                ["priorityName_E"] = "الأولوية",
                ["requiresLocation"] = "يتطلب موقع",
                ["allowsChildTickets"] = "تذاكر فرعية",
                ["requiresQualityReview"] = "مراجعة جودة",
                ["serviceActive"] = "نشط"
            };
            var serviceHidden = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "serviceID", "idaraID_FK", "ticketClassID_FK", "defaultPriorityID_FK",
                "serviceName_E", "ticketClassName_E", "priorityName_E", "serviceActive"
            };

            var serviceModel = BuildLookupTab(
                dt1, "serviceID", "services", "الخدمات", "fa-solid fa-concierge-bell", 1, true,
                "INSERT_SERVICE", "UPDATE_SERVICE", "DELETE_SERVICE",
                canInsertService, canUpdateService, canDeleteService,
                serviceHeaderMap, serviceHidden,
                new List<FieldConfig>
                {
                    new() { Label = "كود الخدمة", Name = "p02", Type = "text", Required = true, ColCss = "6", MaxLength = 50 },
                    new() { Label = "اسم الخدمة (عربي)", Name = "p03", Type = "text", Required = true, ColCss = "6", MaxLength = 200, TextMode = "arabic" },
                    new() { Label = "اسم الخدمة (إنجليزي)", Name = "p04", Type = "text", Required = true, ColCss = "6", MaxLength = 200, TextMode = "english" },
                    new() { Label = "الوصف", Name = "p05", Type = "textarea", ColCss = "12", MaxLength = 1000 },
                    new() { Label = "فئة التذكرة", Name = "p06", Type = "select", Options = ticketClassOptions, ColCss = "6", Select2 = true },
                    new() { Label = "الأولوية الافتراضية", Name = "p07", Type = "select", Options = priorityOptions, ColCss = "6", Select2 = true },
                    new() { Label = "يتطلب موقع", Name = "p08", Type = "checkbox", ColCss = "4" },
                    new() { Label = "يسمح بتذاكر فرعية", Name = "p09", Type = "checkbox", ColCss = "4" },
                    new() { Label = "يتطلب مراجعة جودة", Name = "p10", Type = "checkbox", ColCss = "4" }
                },
                new List<FieldConfig>
                {
                    new() { Label = "كود الخدمة", Name = "p02", Type = "text", Required = true, ColCss = "6", MaxLength = 50 },
                    new() { Label = "اسم الخدمة (عربي)", Name = "p03", Type = "text", Required = true, ColCss = "6", MaxLength = 200 },
                    new() { Label = "اسم الخدمة (إنجليزي)", Name = "p04", Type = "text", ColCss = "6", MaxLength = 200 },
                    new() { Label = "الوصف", Name = "p05", Type = "textarea", ColCss = "12", MaxLength = 1000 },
                    new() { Label = "فئة التذكرة", Name = "p06", Type = "select", Options = ticketClassOptions, ColCss = "6", Select2 = true },
                    new() { Label = "الأولوية الافتراضية", Name = "p07", Type = "select", Options = priorityOptions, ColCss = "6", Select2 = true },
                    new() { Label = "يتطلب موقع", Name = "p08", Type = "checkbox", ColCss = "4" },
                    new() { Label = "يسمح بتذاكر فرعية", Name = "p09", Type = "checkbox", ColCss = "4" },
                    new() { Label = "يتطلب مراجعة جودة", Name = "p10", Type = "checkbox", ColCss = "4" }
                }
            );
            serviceModel.StyleRules = new List<TableStyleRule>
            {
                new() { Target="row", Field="priorityName_A", Op="eq", Value="حرج", Priority=2,
                    PillEnabled=true, PillField="priorityName_A", PillTextField="priorityName_A",
                    PillCssClass="pill pill-red", PillMode="replace" },
                new() { Target="row", Field="priorityName_A", Op="eq", Value="عالي", Priority=2,
                    PillEnabled=true, PillField="priorityName_A", PillTextField="priorityName_A",
                    PillCssClass="pill pill-orange", PillMode="replace" },
                new() { Target="row", Field="priorityName_A", Op="eq", Value="متوسط", Priority=2,
                    PillEnabled=true, PillField="priorityName_A", PillTextField="priorityName_A",
                    PillCssClass="pill pill-blue", PillMode="replace" },
                new() { Target="row", Field="priorityName_A", Op="eq", Value="منخفض", Priority=2,
                    PillEnabled=true, PillField="priorityName_A", PillTextField="priorityName_A",
                    PillCssClass="pill pill-green", PillMode="replace" }
            };

            // ---- Column filters for services tab (ported from ServiceCatalog) ----
            if (dt1 != null && dt1.Rows.Count > 0)
            {
                var classFilterVals = dt1.AsEnumerable()
                    .Select(r => r.Table.Columns.Contains("ticketClassName_A") && r["ticketClassName_A"] != DBNull.Value ? r["ticketClassName_A"]?.ToString()?.Trim() : "")
                    .Where(s => !string.IsNullOrWhiteSpace(s))
                    .Distinct().OrderBy(s => s)
                    .Select(s => new OptionItem { Value = s!, Text = s! }).ToList();

                var priorityFilterVals = dt1.AsEnumerable()
                    .Select(r => r.Table.Columns.Contains("priorityName_A") && r["priorityName_A"] != DBNull.Value ? r["priorityName_A"]?.ToString()?.Trim() : "")
                    .Where(s => !string.IsNullOrWhiteSpace(s))
                    .Distinct().OrderBy(s => s)
                    .Select(s => new OptionItem { Value = s!, Text = s! }).ToList();

                foreach (var col in serviceModel.Columns)
                {
                    if (col.Field == "ticketClassName_A" && classFilterVals.Count > 0)
                        col.Filter = new TableColumnFilter { Enabled = true, Type = "select", Options = classFilterVals };
                    else if (col.Field == "priorityName_A" && priorityFilterVals.Count > 0)
                        col.Filter = new TableColumnFilter { Enabled = true, Type = "select", Options = priorityFilterVals };
                }
            }

            var genericHeaderMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                ["ticketClassID"] = "رقم الفئة", ["ticketClassCode"] = "الكود", ["ticketClassName_A"] = "الاسم (عربي)",
                ["ticketClassName_E"] = "الاسم (إنجليزي)", ["ticketClassDesc"] = "الوصف", ["ticketClassActive"] = "نشط",
                ["entryDate"] = "تاريخ الإنشاء", ["entryData"] = "المستخدم",
                ["priorityID"] = "رقم الأولوية", ["priorityCode"] = "الكود", ["priorityName_A"] = "الاسم (عربي)",
                ["priorityName_E"] = "الاسم (إنجليزي)", ["priorityDesc"] = "الوصف", ["priorityLevel"] = "المستوى",
                ["priorityActive"] = "نشط",
                ["ticketStatusID"] = "رقم الحالة", ["ticketStatusCode"] = "الكود", ["ticketStatusName_A"] = "الاسم (عربي)",
                ["ticketStatusName_E"] = "الاسم (إنجليزي)", ["ticketStatusDesc"] = "الوصف", ["ticketStatusActive"] = "نشط",
                ["pauseReasonID"] = "رقم السبب", ["pauseReasonCode"] = "الكود", ["pauseReasonName_A"] = "الاسم (عربي)",
                ["pauseReasonName_E"] = "الاسم (إنجليزي)", ["pauseReasonDesc"] = "الوصف", ["pauseReasonActive"] = "نشط",
                ["arbitrationReasonID"] = "رقم السبب", ["arbitrationReasonCode"] = "الكود", ["arbitrationReasonName_A"] = "الاسم (عربي)",
                ["arbitrationReasonName_E"] = "الاسم (إنجليزي)", ["arbitrationReasonDesc"] = "الوصف", ["arbitrationReasonActive"] = "نشط",
                ["qualityReviewResultID"] = "رقم النتيجة", ["qualityReviewResultCode"] = "الكود", ["qualityReviewResultName_A"] = "الاسم (عربي)",
                ["qualityReviewResultName_E"] = "الاسم (إنجليزي)", ["qualityReviewResultDesc"] = "الوصف", ["qualityReviewResultActive"] = "نشط"
            };

            var lookupHidden = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "ticketClassID", "ticketClassName_E", "ticketClassActive", "entryData", "hostName",
                "priorityID", "priorityName_E", "priorityActive",
                "ticketStatusID", "ticketStatusName_E", "ticketStatusActive",
                "pauseReasonID", "pauseReasonName_E", "pauseReasonActive",
                "arbitrationReasonID", "arbitrationReasonName_E", "arbitrationReasonActive",
                "qualityReviewResultID", "qualityReviewResultName_E", "qualityReviewResultActive"
            };

            var classModel = BuildLookupTab(
                dtClass, "ticketClassID", "ticket-classes", "فئات التذاكر", "fa-solid fa-layer-group", 2, false,
                "INSERT_TICKETCLASS", "UPDATE_TICKETCLASS", "DELETE_TICKETCLASS",
                canInsertClass, canUpdateClass, canDeleteClass,
                genericHeaderMap, lookupHidden,
                new List<FieldConfig>
                {
                    new() { Label = "الكود", Name = "p02", Type = "text", Required = true, ColCss = "6", MaxLength = 50, TextMode = "english" },
                    new() { Label = "الاسم (عربي)", Name = "p03", Type = "text", Required = true, ColCss = "6", MaxLength = 200, TextMode = "arabic" },
                    new() { Label = "الاسم (إنجليزي)", Name = "p04", Type = "text", ColCss = "6", MaxLength = 200, TextMode = "english" },
                    new() { Label = "الوصف", Name = "p05", Type = "textarea", ColCss = "12", MaxLength = 1000 }
                },
                new List<FieldConfig>
                {
                    new() { Label = "الكود", Name = "p02", Type = "text", Required = true, ColCss = "6", MaxLength = 50 },
                    new() { Label = "الاسم (عربي)", Name = "p03", Type = "text", Required = true, ColCss = "6", MaxLength = 200 },
                    new() { Label = "الاسم (إنجليزي)", Name = "p04", Type = "text", ColCss = "6", MaxLength = 200 },
                    new() { Label = "الوصف", Name = "p05", Type = "textarea", ColCss = "12", MaxLength = 1000 }
                }
            );

            var priorityHeaderMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                ["priorityID"] = "رقم الأولوية", ["priorityCode"] = "الكود", ["priorityName_A"] = "الاسم (عربي)",
                ["priorityName_E"] = "الاسم (إنجليزي)", ["priorityDesc"] = "الوصف", ["priorityLevel"] = "المستوى",
                ["priorityActive"] = "نشط", ["entryDate"] = "تاريخ الإنشاء"
            };
            var priorityHidden2 = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "priorityID", "priorityName_E", "priorityActive", "entryData", "hostName"
            };

            var priorityModel = BuildLookupTab(
                dtPriority, "priorityID", "priorities", "الأولويات", "fa-solid fa-signal", 3, false,
                "INSERT_PRIORITY", "UPDATE_PRIORITY", "DELETE_PRIORITY",
                canInsertPriority, canUpdatePriority, canDeletePriority,
                priorityHeaderMap, priorityHidden2,
                new List<FieldConfig>
                {
                    new() { Label = "الكود", Name = "p02", Type = "text", Required = true, ColCss = "4", MaxLength = 50, TextMode = "english" },
                    new() { Label = "الاسم (عربي)", Name = "p03", Type = "text", Required = true, ColCss = "4", MaxLength = 200, TextMode = "arabic" },
                    new() { Label = "الاسم (إنجليزي)", Name = "p04", Type = "text", ColCss = "4", MaxLength = 200, TextMode = "english" },
                    new() { Label = "الوصف", Name = "p05", Type = "textarea", ColCss = "12", MaxLength = 1000 },
                    new() { Label = "المستوى", Name = "p06", Type = "text", ColCss = "6", TextMode = "number", RequiredMsg = "الرجاء إدخال المستوى" }
                },
                new List<FieldConfig>
                {
                    new() { Label = "الكود", Name = "p02", Type = "text", Required = true, ColCss = "4", MaxLength = 50 },
                    new() { Label = "الاسم (عربي)", Name = "p03", Type = "text", Required = true, ColCss = "4", MaxLength = 200 },
                    new() { Label = "الاسم (إنجليزي)", Name = "p04", Type = "text", ColCss = "4", MaxLength = 200 },
                    new() { Label = "الوصف", Name = "p05", Type = "textarea", ColCss = "12", MaxLength = 1000 },
                    new() { Label = "المستوى", Name = "p06", Type = "text", ColCss = "6", TextMode = "number" }
                }
            );
            priorityModel.StyleRules = new List<TableStyleRule>
            {
                new() { Target="row", Field="priorityCode", Op="eq", Value="CRITICAL", Priority=1,
                    PillEnabled=true, PillField="priorityName_A", PillTextField="priorityName_A",
                    PillCssClass="pill pill-red", PillMode="replace" },
                new() { Target="row", Field="priorityCode", Op="eq", Value="HIGH", Priority=1,
                    PillEnabled=true, PillField="priorityName_A", PillTextField="priorityName_A",
                    PillCssClass="pill pill-orange", PillMode="replace" },
                new() { Target="row", Field="priorityCode", Op="eq", Value="MEDIUM", Priority=1,
                    PillEnabled=true, PillField="priorityName_A", PillTextField="priorityName_A",
                    PillCssClass="pill pill-blue", PillMode="replace" },
                new() { Target="row", Field="priorityCode", Op="eq", Value="LOW", Priority=1,
                    PillEnabled=true, PillField="priorityName_A", PillTextField="priorityName_A",
                    PillCssClass="pill pill-green", PillMode="replace" },
                new() { Target="row", Field="priorityCode", Op="eq", Value="PLANNED", Priority=1,
                    PillEnabled=true, PillField="priorityName_A", PillTextField="priorityName_A",
                    PillCssClass="pill pill-gray", PillMode="replace" }
            };

            var statusHeaderMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                ["ticketStatusID"] = "رقم الحالة", ["ticketStatusCode"] = "الكود", ["ticketStatusName_A"] = "الاسم (عربي)",
                ["ticketStatusName_E"] = "الاسم (إنجليزي)", ["ticketStatusDesc"] = "الوصف", ["ticketStatusActive"] = "نشط",
                ["entryDate"] = "تاريخ الإنشاء"
            };
            var statusHidden = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "ticketStatusID", "ticketStatusName_E", "ticketStatusActive", "entryData", "hostName"
            };

            var statusModel = BuildLookupTab(
                dtStatus, "ticketStatusID", "statuses", "حالات التذكرة", "fa-solid fa-circle-half-stroke", 4, false,
                "INSERT_TICKETSTATUS", "UPDATE_TICKETSTATUS", "DELETE_TICKETSTATUS",
                canInsertStatus, canUpdateStatus, canDeleteStatus,
                statusHeaderMap, statusHidden,
                new List<FieldConfig>
                {
                    new() { Label = "الكود", Name = "p02", Type = "text", Required = true, ColCss = "6", MaxLength = 50, TextMode = "english" },
                    new() { Label = "الاسم (عربي)", Name = "p03", Type = "text", Required = true, ColCss = "6", MaxLength = 200, TextMode = "arabic" },
                    new() { Label = "الاسم (إنجليزي)", Name = "p04", Type = "text", ColCss = "6", MaxLength = 200, TextMode = "english" },
                    new() { Label = "الوصف", Name = "p05", Type = "textarea", ColCss = "12", MaxLength = 1000 }
                },
                new List<FieldConfig>
                {
                    new() { Label = "الكود", Name = "p02", Type = "text", Required = true, ColCss = "6", MaxLength = 50 },
                    new() { Label = "الاسم (عربي)", Name = "p03", Type = "text", Required = true, ColCss = "6", MaxLength = 200 },
                    new() { Label = "الاسم (إنجليزي)", Name = "p04", Type = "text", ColCss = "6", MaxLength = 200 },
                    new() { Label = "الوصف", Name = "p05", Type = "textarea", ColCss = "12", MaxLength = 1000 }
                }
            );
            statusModel.StyleRules = new List<TableStyleRule>
            {
                new() { Target="row", Field="ticketStatusCode", Op="eq", Value="NEW", Priority=1,
                    PillEnabled=true, PillField="ticketStatusName_A", PillTextField="ticketStatusName_A",
                    PillCssClass="pill pill-gray", PillMode="replace" },
                new() { Target="row", Field="ticketStatusCode", Op="eq", Value="IN_PROGRESS", Priority=1,
                    PillEnabled=true, PillField="ticketStatusName_A", PillTextField="ticketStatusName_A",
                    PillCssClass="pill pill-green", PillMode="replace" },
                new() { Target="row", Field="ticketStatusCode", Op="eq", Value="RESOLVED", Priority=1,
                    PillEnabled=true, PillField="ticketStatusName_A", PillTextField="ticketStatusName_A",
                    PillCssClass="pill pill-green", PillMode="replace" },
                new() { Target="row", Field="ticketStatusCode", Op="eq", Value="CLOSED", Priority=1,
                    PillEnabled=true, PillField="ticketStatusName_A", PillTextField="ticketStatusName_A",
                    PillCssClass="pill pill-gray", PillMode="replace" },
                new() { Target="row", Field="ticketStatusCode", Op="eq", Value="REJECTED", Priority=1,
                    PillEnabled=true, PillField="ticketStatusName_A", PillTextField="ticketStatusName_A",
                    PillCssClass="pill pill-red", PillMode="replace" },
                new() { Target="row", Field="ticketStatusCode", Op="eq", Value="ARBITRATION", Priority=1,
                    PillEnabled=true, PillField="ticketStatusName_A", PillTextField="ticketStatusName_A",
                    PillCssClass="pill pill-purple", PillMode="replace" },
                new() { Target="row", Field="ticketStatusCode", Op="eq", Value="PAUSED", Priority=1,
                    PillEnabled=true, PillField="ticketStatusName_A", PillTextField="ticketStatusName_A",
                    PillCssClass="pill pill-orange", PillMode="replace" }
            };

            // ---- Merged Lookups Tab: Pause Reasons + Arb Reasons + Quality Review Results ----
            var mergedColumns = new List<TableColumn>
            {
                new() { Field = "lookupCategory", Label = "النوع", Type = "text", Sortable = true, Visible = true },
                new() { Field = "lookupCode", Label = "الكود", Type = "text", Sortable = true, Visible = true },
                new() { Field = "lookupName_A", Label = "الاسم (عربي)", Type = "text", Sortable = true, Visible = true },
                new() { Field = "lookupName_E", Label = "الاسم (إنجليزي)", Type = "text", Sortable = true, Visible = false },
                new() { Field = "lookupDesc", Label = "الوصف", Type = "text", Sortable = true, Visible = true },
                new() { Field = "entryDate", Label = "تاريخ الإنشاء", Type = "text", Sortable = true, Visible = false }
            };

            var mergedRows = new List<Dictionary<string, object?>>();

            void AppendLookupRows(DataTable? dt, string categoryLabel, string categoryCode, string idCol, string codeCol, string nameACol, string nameECol, string descCol)
            {
                if (dt == null || dt.Columns.Count == 0) return;
                foreach (DataRow dr in dt.Rows)
                {
                    var dict = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
                    dict["lookupCategory"] = categoryLabel;
                    dict["lookupCategoryCode"] = categoryCode;
                    dict["lookupID"] = dr[idCol] == DBNull.Value ? null : dr[idCol];
                    dict["lookupCode"] = dr[codeCol] == DBNull.Value ? null : dr[codeCol];
                    dict["lookupName_A"] = dr[nameACol] == DBNull.Value ? null : dr[nameACol];
                    dict["lookupName_E"] = dt.Columns.Contains(nameECol) && dr[nameECol] != DBNull.Value ? dr[nameECol] : null;
                    dict["lookupDesc"] = dt.Columns.Contains(descCol) && dr[descCol] != DBNull.Value ? dr[descCol] : null;
                    dict["entryDate"] = dt.Columns.Contains("entryDate") && dr["entryDate"] != DBNull.Value ? dr["entryDate"] : null;
                    dict["p01"] = dict["lookupID"];
                    mergedRows.Add(dict);
                }
            }

            AppendLookupRows(dtPauseReason, "أسباب الإيقاف", "PAUSE", "pauseReasonID", "pauseReasonCode", "pauseReasonName_A", "pauseReasonName_E", "pauseReasonDesc");
            AppendLookupRows(dtArbReason, "أسباب التحكيم", "ARB", "arbitrationReasonID", "arbitrationReasonCode", "arbitrationReasonName_A", "arbitrationReasonName_E", "arbitrationReasonDesc");
            AppendLookupRows(dtQRR, "نتائج المراجعة", "QRR", "qualityReviewResultID", "qualityReviewResultCode", "qualityReviewResultName_A", "qualityReviewResultName_E", "qualityReviewResultDesc");

            var categoryFilterVals = mergedRows
                .Select(r => r["lookupCategory"]?.ToString()?.Trim())
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .Distinct().OrderBy(s => s)
                .Select(s => new OptionItem { Value = s!, Text = s! }).ToList();

            foreach (var col in mergedColumns)
            {
                if (col.Field == "lookupCategory" && categoryFilterVals.Count > 0)
                    col.Filter = new TableColumnFilter { Enabled = true, Type = "select", Options = categoryFilterVals };
            }

            var mergedLookupFormFields = new List<FieldConfig>
            {
                new() { Label = "الكود", Name = "p02", Type = "text", Required = true, ColCss = "6", MaxLength = 50, TextMode = "english" },
                new() { Label = "الاسم (عربي)", Name = "p03", Type = "text", Required = true, ColCss = "6", MaxLength = 200, TextMode = "arabic" },
                new() { Label = "الاسم (إنجليزي)", Name = "p04", Type = "text", ColCss = "6", MaxLength = 200, TextMode = "english" },
                new() { Label = "الوصف", Name = "p05", Type = "textarea", ColCss = "12", MaxLength = 1000 }
            };

            bool canAnyMergedInsert = canInsertPauseReason || canInsertArbReason || canInsertQRR;
            bool canAnyMergedUpdate = canUpdatePauseReason || canUpdateArbReason || canUpdateQRR;
            bool canAnyMergedDelete = canDeletePauseReason || canDeleteArbReason || canDeleteQRR;

            var mergedToolbar = new TableToolbarConfig
            {
                ShowRefresh = true,
                ShowColumns = true,
                ShowExportExcel = true,
                ShowEdit = false,
                ShowDelete = false,
                ShowAdd = false
            };

            var mergedCustomActions = new List<TableAction>();

            string dynActionJs = @"(function(){var r=table.getSelectedRows();if(!r||!r.length)return;var c=r[0].lookupCategoryCode||r[0]['lookupCategoryCode']||'';var prefix='';if(c==='PAUSE')prefix='PAUSEREASON';else if(c==='ARB')prefix='ARBITRATIONREASON';else if(c==='QRR')prefix='QUALITYREVIEWRESULT';var f=act.openForm||act.OpenForm;if(!f)return;var fs=f.fields||f.Fields;if(!fs)return;fs.forEach(function(fd){if(fd.name==='ActionType'||fd.Name==='ActionType'){fd.value=prefix;fd.Value=prefix;}});})()";

            if (canInsertPauseReason)
            {
                var fields = BuildCrudFields(crudPageName, "INSERT_PAUSEREASON", currentUrl, mergedLookupFormFields);
                mergedCustomActions.Add(new TableAction
                {
                    Label = "سبب إيقاف +", Icon = "fa fa-pause-circle", Color = "warning",
                    OpenModal = true, ModalTitle = "إضافة سبب إيقاف",
                    ModalMessage = "ملاحظة: جميع التعديلات مرصودة", ModalMessageIcon = "fa-solid fa-circle-info", ModalMessageClass = "bg-sky-100 text-sky-700",
                    OpenForm = new FormConfig
                    {
                        FormId = "mergedPauseInsertForm", Title = "إضافة سبب إيقاف", Method = "post", ActionUrl = "/crud/insert",
                        Fields = fields,
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "حفظ", Type = "submit", Color = "success", Icon = "fa fa-check" },
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" }
                        }
                    }
                });
            }

            if (canInsertArbReason)
            {
                var fields = BuildCrudFields(crudPageName, "INSERT_ARBITRATIONREASON", currentUrl, mergedLookupFormFields);
                mergedCustomActions.Add(new TableAction
                {
                    Label = "سبب تحكيم +", Icon = "fa fa-gavel", Color = "info",
                    OpenModal = true, ModalTitle = "إضافة سبب تحكيم",
                    ModalMessage = "ملاحظة: جميع التعديلات مرصودة", ModalMessageIcon = "fa-solid fa-circle-info", ModalMessageClass = "bg-sky-100 text-sky-700",
                    OpenForm = new FormConfig
                    {
                        FormId = "mergedArbInsertForm", Title = "إضافة سبب تحكيم", Method = "post", ActionUrl = "/crud/insert",
                        Fields = fields,
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "حفظ", Type = "submit", Color = "success", Icon = "fa fa-check" },
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" }
                        }
                    }
                });
            }

            if (canInsertQRR)
            {
                var fields = BuildCrudFields(crudPageName, "INSERT_QUALITYREVIEWRESULT", currentUrl, mergedLookupFormFields);
                mergedCustomActions.Add(new TableAction
                {
                    Label = "نتيجة مراجعة +", Icon = "fa fa-clipboard-check", Color = "success",
                    OpenModal = true, ModalTitle = "إضافة نتيجة مراجعة",
                    ModalMessage = "ملاحظة: جميع التعديلات مرصودة", ModalMessageIcon = "fa-solid fa-circle-info", ModalMessageClass = "bg-sky-100 text-sky-700",
                    OpenForm = new FormConfig
                    {
                        FormId = "mergedQrrInsertForm", Title = "إضافة نتيجة مراجعة", Method = "post", ActionUrl = "/crud/insert",
                        Fields = fields,
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "حفظ", Type = "submit", Color = "success", Icon = "fa fa-check" },
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" }
                        }
                    }
                });
            }

            if (canAnyMergedUpdate)
            {
                var editFields = BuildCrudFields(crudPageName, "UPDATE_PAUSEREASON", currentUrl, mergedLookupFormFields, hasP01: true);
                mergedCustomActions.Add(new TableAction
                {
                    Label = "تعديل", Icon = "fa fa-pen-to-square", Color = "info",
                    IsEdit = true, RequireSelection = true, MinSelection = 1, MaxSelection = 1,
                    OpenModal = true, ModalTitle = "تعديل",
                    OnBeforeOpenJs = dynActionJs,
                    OpenForm = new FormConfig
                    {
                        FormId = "mergedLookupEditForm", Title = "تعديل", Method = "post", ActionUrl = "/crud/update",
                        Fields = editFields,
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "حفظ التعديلات", Type = "submit", Color = "info", Icon = "fa fa-check" },
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" }
                        }
                    }
                });
            }

            if (canAnyMergedDelete)
            {
                var deleteFields = BuildCrudFields(crudPageName, "DELETE_PAUSEREASON", currentUrl,
                    new List<FieldConfig> { new() { Name = "p01", Type = "hidden" } }, hasP01: true, isDelete: true);
                mergedCustomActions.Add(new TableAction
                {
                    Label = "حذف", Icon = "fa fa-trash", Color = "danger",
                    IsEdit = true, RequireSelection = true, MinSelection = 1, MaxSelection = 1,
                    OpenModal = true, ModalTitle = "تحذير",
                    ModalMessage = "هل أنت متأكد من الحذف؟", ModalMessageIcon = "fa fa-exclamation-triangle text-red-600", ModalMessageClass = "bg-red-50 text-red-700",
                    OnBeforeOpenJs = dynActionJs,
                    OpenForm = new FormConfig
                    {
                        FormId = "mergedLookupDeleteForm", Title = "تأكيد الحذف", Method = "post", ActionUrl = "/crud/delete",
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "حذف", Type = "submit", Color = "danger", Icon = "fa fa-trash" },
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" }
                        },
                        Fields = deleteFields
                    }
                });
            }

            mergedToolbar.CustomActions = mergedCustomActions;

            var mergedLookupModel = new SmartTableDsModel
            {
                PageTitle = "القوائم المرجعية",
                PanelTitle = "القوائم المرجعية",
                Columns = mergedColumns,
                Rows = mergedRows,
                RowIdField = "p01",
                PageSize = 10,
                PageSizes = new List<int> { 10, 25, 50, 100 },
                Searchable = true,
                AllowExport = true,
                ShowPageSizeSelector = true,
                EnableCellCopy = true,
                ShowColumnVisibility = true,
                QuickSearchFields = mergedColumns.Where(c => c.Visible).Select(c => c.Field).Take(4).ToList(),
                Toolbar = mergedToolbar,
                RenderMode = SmartTableRenderMode.Tab,
                RenderAsTab = true,
                TabGroupKey = tabGroupKey,
                TabKey = "merged-lookups",
                TabLabel = "القوائم المرجعية",
                TabIcon = "fa-solid fa-list-check",
                TabDefaultActive = false,
                ShowTabCount = true,
                TabOrder = 5,
                ShowToolbar = true,
                EnablePagination = true
            };
            mergedLookupModel.StyleRules = new List<TableStyleRule>
            {
                new() { Target="row", Field="lookupCategory", Op="eq", Value="أسباب الإيقاف", Priority=1,
                    PillEnabled=true, PillField="lookupCategory", PillTextField="lookupCategory",
                    PillCssClass="pill pill-orange", PillMode="replace" },
                new() { Target="row", Field="lookupCategory", Op="eq", Value="أسباب التحكيم", Priority=1,
                    PillEnabled=true, PillField="lookupCategory", PillTextField="lookupCategory",
                    PillCssClass="pill pill-purple", PillMode="replace" },
                new() { Target="row", Field="lookupCategory", Op="eq", Value="نتائج المراجعة", Priority=1,
                    PillEnabled=true, PillField="lookupCategory", PillTextField="lookupCategory",
                    PillCssClass="pill pill-blue", PillMode="replace" }
            };

            var page = new SmartPageViewModel
            {
                PageTitle = "إدارة نظام التذاكر",
                PanelTitle = "إدارة نظام التذاكر",
                PanelIcon = "fa-solid fa-sliders",
                TableDS = serviceModel,
                TableDS1 = classModel,
                TableDS2 = priorityModel,
                TableDS3 = statusModel,
                TableDS4 = mergedLookupModel
            };

            return View("TicketAdmin", page);
        }

        private List<FieldConfig> BuildCrudFields(string pageName, string actionType, string redirectUrl,
            List<FieldConfig> visibleFields, bool hasP01 = false, bool isDelete = false, string redirectAction = "TicketAdmin")
        {
            var fields = new List<FieldConfig>
            {
                new() { Name = "redirectUrl", Type = "hidden", Value = redirectUrl },
                new() { Name = "redirectController", Type = "hidden", Value = ControllerName },
                new() { Name = "redirectAction", Type = "hidden", Value = redirectAction },
                new() { Name = "pageName_", Type = "hidden", Value = pageName },
                new() { Name = "ActionType", Type = "hidden", Value = actionType },
                new() { Name = "idaraID", Type = "hidden", Value = IdaraId },
                new() { Name = "entrydata", Type = "hidden", Value = usersId },
                new() { Name = "hostname", Type = "hidden", Value = HostName }
            };

            if (hasP01)
                fields.Add(new FieldConfig { Name = "p01", Type = "hidden" });

            fields.AddRange(visibleFields);
            return fields;
        }
    }
}
