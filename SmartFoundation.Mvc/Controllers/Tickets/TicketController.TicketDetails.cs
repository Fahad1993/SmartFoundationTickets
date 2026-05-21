using Microsoft.AspNetCore.Mvc;
using SmartFoundation.UI.ViewModels.SmartForm;
using SmartFoundation.UI.ViewModels.SmartPage;
using SmartFoundation.UI.ViewModels.SmartTable;
using System.Data;
using System.Text.Json;

namespace SmartFoundation.Mvc.Controllers.Tickets
{
    public partial class TicketController : Controller
    {
        public async Task<IActionResult> TicketDetails(int? id)
        {
            if (!InitPageContext(out var redirect))
                return redirect!;

            if (string.IsNullOrWhiteSpace(usersId))
                return RedirectToAction("Index", "Login", new { logout = 4 });

            ControllerName = nameof(TicketController).Replace("Controller", "");
            PageName = "TicketDetails";

            var spParameters = new object?[]
            {
                PageName,
                IdaraId,
                usersId,
                HostName,
                id?.ToString()
            };

            DataSet ds = await _mastersServies.GetDataLoadDataSetAsync(spParameters);
            SplitDataSet(ds);

            if (permissionTable is null || permissionTable.Rows.Count == 0)
            {
                TempData["Error"] = "تم رصد دخول غير مصرح به";
                return RedirectToAction("Index", "Home");
            }

            bool canAssignTicket = false;
            bool canStartWork = false;
            bool canResolveTicket = false;
            bool canPauseTicket = false;
            bool canResumeTicket = false;
            bool canRaiseArbitration = false;
            bool canCreateChildTicket = false;
            bool canRequestClarification = false;
            bool canRespondClarification = false;

            foreach (DataRow row in permissionTable.Rows)
            {
                var perm = row["permissionTypeName_E"]?.ToString()?.Trim().ToUpperInvariant();
                if (perm == "ASSIGN_TICKET") canAssignTicket = true;
                if (perm == "START_WORK") canStartWork = true;
                if (perm == "RESOLVE_TICKET") canResolveTicket = true;
                if (perm == "PAUSE_TICKET") canPauseTicket = true;
                if (perm == "RESUME_TICKET") canResumeTicket = true;
                if (perm == "RAISE_ARBITRATION") canRaiseArbitration = true;
                if (perm == "CREATE_CHILD_TICKET") canCreateChildTicket = true;
                if (perm == "REQUEST_CLARIFICATION") canRequestClarification = true;
                if (perm == "RESPOND_CLARIFICATION") canRespondClarification = true;
            }

            // ---- Search form (Housing InlineButton pattern) ----
            var searchForm = new FormConfig
            {
                Fields = new List<FieldConfig>
                {
                    new()
                    {
                        SectionTitle = "البحث عن تذكرة",
                        Label = "رقم التذكرة",
                        Name = "id",
                        Type = "text",
                        ColCss = "3",
                        Icon = "fa-solid fa-ticket",
                        Placeholder = "أدخل رقم التذكرة",
                        Value = id?.ToString(),
                        Required = true,
                        IsNumericOnly = false,
                        SubmitOnEnter = true,
                        InlineButton = true,
                        InlineButtonText = "بحـث",
                        InlineButtonIcon = "fa-solid fa-magnifying-glass",
                        InlineButtonCss = "btn btn-success",
                        InlineButtonPosition = "end",
                        InlineButtonOnClickJs = "sfNav(this)",
                        NavUrl = "/Ticket/TicketDetails",
                        NavKey = "id"
                    }
                }
            };

            if (id == null || id <= 0)
            {
                var defaultTicketId = await TryGetLatestTicketIdAsync();
                if (defaultTicketId.HasValue)
                {
                    return RedirectToAction(nameof(TicketDetails), new { id = defaultTicketId.Value });
                }

                return View("TicketDetails", new SmartPageViewModel
                {
                    PageTitle = "تفاصيل التذكرة",
                    PanelTitle = "تفاصيل التذكرة",
                    PanelIcon = "fa fa-ticket",
                    Form = searchForm
                });
            }

            var ticketId = id.Value;
            var safeIdaraId = IdaraId ?? string.Empty;
            var safeEntryData = usersId ?? string.Empty;
            var safeHostName = HostName ?? string.Empty;
            var ticketDetailsRedirectUrl = Url.Action(nameof(TicketDetails), "Ticket", new { id = ticketId }) ?? string.Empty;

            var ticketTable = ResolveUsableTable(ds, "ticketID", "ticketNo");

            if (ticketTable == null || ticketTable.Rows.Count == 0)
            {
                TempData["Warning"] = "لم يتم العثور على التذكرة رقم: " + id;
                return View("TicketDetails", new SmartPageViewModel
                {
                    PageTitle = "تفاصيل التذكرة",
                    PanelTitle = "تفاصيل التذكرة",
                    PanelIcon = "fa fa-ticket",
                    Form = searchForm
                });
            }

            var ticketRow = new Dictionary<string, object?>();
            if (ticketTable != null && ticketTable.Rows.Count > 0)
            {
                foreach (DataColumn col in ticketTable.Columns)
                    ticketRow[col.ColumnName] = ticketTable.Rows[0][col] == DBNull.Value ? null : ticketTable.Rows[0][col];
            }

            // Ensure critical fields exist even if null
            if (!ticketRow.ContainsKey("ticketID")) ticketRow["ticketID"] = id?.ToString();
            if (!ticketRow.ContainsKey("ticketNo") || string.IsNullOrEmpty(ticketRow.GetValueOrDefault("ticketNo")?.ToString())) ticketRow["ticketNo"] = $"#{id}";
            if (!ticketRow.ContainsKey("title")) ticketRow["title"] = "بدون عنوان";
            if (!ticketRow.ContainsKey("ticketStatusCode") || string.IsNullOrEmpty(ticketRow.GetValueOrDefault("ticketStatusCode")?.ToString())) ticketRow["ticketStatusCode"] = "NEW";
            if (!ticketRow.ContainsKey("ticketStatusName_A") || string.IsNullOrEmpty(ticketRow.GetValueOrDefault("ticketStatusName_A")?.ToString())) ticketRow["ticketStatusName_A"] = "جديد";
            if (!ticketRow.ContainsKey("priorityCode") || string.IsNullOrEmpty(ticketRow.GetValueOrDefault("priorityCode")?.ToString())) ticketRow["priorityCode"] = "MEDIUM";
            if (!ticketRow.ContainsKey("priorityName_A") || string.IsNullOrEmpty(ticketRow.GetValueOrDefault("priorityName_A")?.ToString())) ticketRow["priorityName_A"] = "متوسط";
            if (!ticketRow.ContainsKey("ticketClassName_A")) ticketRow["ticketClassName_A"] = "عام";
            if (!ticketRow.ContainsKey("assignedUserName") || string.IsNullOrEmpty(ticketRow.GetValueOrDefault("assignedUserName")?.ToString())) ticketRow["assignedUserName"] = "--";
            if (!ticketRow.ContainsKey("isParentBlocked")) ticketRow["isParentBlocked"] = "False";
            if (!ticketRow.ContainsKey("currentDSDID_FK")) ticketRow["currentDSDID_FK"] = null;
            if (!ticketRow.ContainsKey("locationBuildingNo")) ticketRow["locationBuildingNo"] = null;
            if (!ticketRow.ContainsKey("locationUnitNo")) ticketRow["locationUnitNo"] = null;
            if (!ticketRow.ContainsKey("locationArea")) ticketRow["locationArea"] = null;
            if (!ticketRow.ContainsKey("entryDate") || string.IsNullOrEmpty(ticketRow.GetValueOrDefault("entryDate")?.ToString())) ticketRow["entryDate"] = DateTime.Now.ToString("yyyy-MM-dd HH:mm");
            if (!ticketRow.ContainsKey("slaElapsedMinutes")) ticketRow["slaElapsedMinutes"] = null;
            if (!ticketRow.ContainsKey("slaTargetMinutes")) ticketRow["slaTargetMinutes"] = null;
            if (!ticketRow.ContainsKey("slaIsBreached")) ticketRow["slaIsBreached"] = "False";
            if (!ticketRow.ContainsKey("slaTypeCode")) ticketRow["slaTypeCode"] = null;
            if (!ticketRow.ContainsKey("serviceName_A")) ticketRow["serviceName_A"] = "غير محدد";
            if (!ticketRow.ContainsKey("requesterName")) ticketRow["requesterName"] = "غير محدد";
            if (!ticketRow.ContainsKey("requesterTypeName_A")) ticketRow["requesterTypeName_A"] = "غير محدد";
            if (!ticketRow.ContainsKey("requiresQualityReview")) ticketRow["requiresQualityReview"] = "False";
            if (!ticketRow.ContainsKey("operationalResolutionDate")) ticketRow["operationalResolutionDate"] = null;
            if (!ticketRow.ContainsKey("finalClosureDate")) ticketRow["finalClosureDate"] = null;
            if (!ticketRow.ContainsKey("serviceID_FK")) ticketRow["serviceID_FK"] = null;
            if (!ticketRow.ContainsKey("allowsChildTickets")) ticketRow["allowsChildTickets"] = "0";

            string statusCode = ticketRow.GetValueOrDefault("ticketStatusCode")?.ToString() ?? "";

            // Header card data for the view
            ViewBag.TicketHeader = new Dictionary<string, string?>
            {
                ["ticketID"] = ticketRow.GetValueOrDefault("ticketID")?.ToString(),
                ["ticketNo"] = ticketRow.GetValueOrDefault("ticketNo")?.ToString(),
                ["serviceID_FK"] = ticketRow.GetValueOrDefault("serviceID_FK")?.ToString(),
                ["statusName"] = ticketRow.GetValueOrDefault("ticketStatusName_A")?.ToString(),
                ["statusCode"] = statusCode,
                ["priorityName"] = ticketRow.GetValueOrDefault("priorityName_A")?.ToString(),
                ["priorityCode"] = ticketRow.GetValueOrDefault("priorityCode")?.ToString(),
                ["allowsChildTickets"] = ticketRow.GetValueOrDefault("allowsChildTickets")?.ToString(),
                ["serviceName"] = ticketRow.GetValueOrDefault("serviceName_A")?.ToString(),
                ["title"] = ticketRow.GetValueOrDefault("title")?.ToString(),
                ["description"] = ticketRow.GetValueOrDefault("description_")?.ToString(),
                ["ticketClassName"] = ticketRow.GetValueOrDefault("ticketClassName_A")?.ToString(),
                ["requesterTypeName"] = ticketRow.GetValueOrDefault("requesterTypeName_A")?.ToString(),
                ["requesterName"] = ticketRow.GetValueOrDefault("requesterName")?.ToString(),
                ["assignedUserName"] = ticketRow.GetValueOrDefault("assignedUserName")?.ToString(),
                ["isBlocked"] = ticketRow.GetValueOrDefault("isParentBlocked")?.ToString(),
                ["currentDSDID_FK"] = ticketRow.GetValueOrDefault("currentDSDID_FK")?.ToString(),
                ["locationBuildingNo"] = ticketRow.GetValueOrDefault("locationBuildingNo")?.ToString(),
                ["locationUnitNo"] = ticketRow.GetValueOrDefault("locationUnitNo")?.ToString(),
                ["locationArea"] = ticketRow.GetValueOrDefault("locationArea")?.ToString(),
                ["entryDate"] = ticketRow.GetValueOrDefault("entryDate")?.ToString(),
                ["slaElapsedMinutes"] = ticketRow.GetValueOrDefault("slaElapsedMinutes")?.ToString(),
                ["slaTargetMinutes"] = ticketRow.GetValueOrDefault("slaTargetMinutes")?.ToString(),
                ["slaIsBreached"] = ticketRow.GetValueOrDefault("slaIsBreached")?.ToString(),
                ["slaTypeCode"] = ticketRow.GetValueOrDefault("slaTypeCode")?.ToString(),
                ["operationalResolutionDate"] = ticketRow.GetValueOrDefault("operationalResolutionDate")?.ToString(),
                ["finalClosureDate"] = ticketRow.GetValueOrDefault("finalClosureDate")?.ToString(),
                ["requiresQualityReview"] = ticketRow.GetValueOrDefault("requiresQualityReview")?.ToString()
            };

            var historyTable = await LoadTicketDataTableAsync(
                "TicketHistory",
                ticketId,
                "actionTypeCode",
                "actionDate");

            // ---- Audit trail (raw list for timeline rendering) ----
            var historyList = ConvertTableToDictionaryList(historyTable);
            ViewBag.TicketAuditTrail = historyList;

            // Compute last-updated date from latest history entry
            if (historyList.Count > 0)
            {
                var lastEntry = historyList[^1];
                var lastUpdated = lastEntry.GetValueOrDefault("actionDate")?.ToString();
                if (!string.IsNullOrWhiteSpace(lastUpdated))
                {
                    var headerDict = (Dictionary<string, string?>)ViewBag.TicketHeader;
                    headerDict["lastUpdated"] = lastUpdated;
                }
            }

            // ---- Child tickets (raw list) ----
            var childTable = await LoadTicketDataTableAsync(
                "ChildTickets",
                ticketId,
                "ticketID",
                "ticketNo");
            var childList = ConvertTableToDictionaryList(childTable);
            ViewBag.ChildTickets = childList;

            // ---- Pause sessions (raw list) ----
            var pauseTable = await LoadTicketDataTableAsync(
                "PauseSessions",
                ticketId,
                "ticketPauseSessionID",
                "pauseStart");
            var pauseList = ConvertTableToDictionaryList(pauseTable);
            ViewBag.PauseSessions = pauseList;

            var qualityReviewTable = await LoadTicketDataTableAsync(
                "QualityReviews",
                ticketId,
                "qualityReviewID",
                "entryDate");
            ViewBag.QualityReviews = ConvertTableToDictionaryList(qualityReviewTable);

            List<OptionItem> pauseReasonOptions = new();
            List<OptionItem> arbitrationReasonOptions = new();
            List<OptionItem> actionPriorityOptions = new();
            List<OptionItem> actionClassOptions = new();
            List<OptionItem> clarificationReasonOptions = new();
            List<OptionItem> clarificationTargetDsdOptions = new();

            if (canPauseTicket)
            {
                pauseReasonOptions = await GetTicketDdlOptionsAsync(
                    "pauseReasonName_A",
                    "pauseReasonID",
                    "1",
                    "PauseReasonDDL");
            }

            if (canRaiseArbitration)
            {
                arbitrationReasonOptions = await GetTicketDdlOptionsAsync(
                    "arbitrationReasonName_A",
                    "arbitrationReasonID",
                    "1",
                    "ArbitrationReasonDDL");
            }

            if (canCreateChildTicket)
            {
                actionPriorityOptions = await GetTicketDdlOptionsAsync(
                    "priorityName_A",
                    "priorityID",
                    "1",
                    "PriorityDDL");
                actionClassOptions = await GetTicketDdlOptionsAsync(
                    "ticketClassName_A",
                    "ticketClassID",
                    "1",
                    "TicketClassDDL");
            }

            if (canRequestClarification)
            {
                clarificationReasonOptions = await GetClarificationReasonOptionsAsync();
                clarificationTargetDsdOptions = await GetServiceCatalogueDsdOptionsAsync();
            }

            var clarificationRequestsTable = await LoadClarificationRequestsFallbackAsync(ticketId);
            ViewBag.ClarificationRequests = ConvertTableToDictionaryList(clarificationRequestsTable);

            long? openClarificationRequestId = null;
            if (canRespondClarification)
            {
                var openClarificationMap = await GetOpenClarificationRequestMapAsync(new[] { (long)ticketId });
                if (openClarificationMap.TryGetValue(ticketId, out var clarificationRequestId))
                    openClarificationRequestId = clarificationRequestId;
            }

            ViewBag.CanAssignTicket = canAssignTicket;
            ViewBag.CanStartWork = canStartWork;
            ViewBag.CanResolveTicket = canResolveTicket;
            ViewBag.CanPauseTicket = canPauseTicket;
            ViewBag.CanResumeTicket = canResumeTicket;
            ViewBag.CanRaiseArbitration = canRaiseArbitration;
            ViewBag.CanCreateChildTicket = canCreateChildTicket;
            ViewBag.CanRequestClarification = canRequestClarification;
            ViewBag.CanRespondClarification = canRespondClarification;
            ViewBag.OpenClarificationRequestId = openClarificationRequestId?.ToString();
            ViewBag.PauseReasonOptions = pauseReasonOptions;
            ViewBag.ArbitrationReasonOptions = arbitrationReasonOptions;
            ViewBag.ActionPriorityOptions = actionPriorityOptions;
            ViewBag.ActionClassOptions = actionClassOptions;
            ViewBag.ClarificationReasonOptions = clarificationReasonOptions;
            ViewBag.ClarificationTargetDsdOptions = clarificationTargetDsdOptions;
            // CRUD context for modals
            ViewBag.TicketDetailsRedirectUrl = ticketDetailsRedirectUrl;
            ViewBag.CrudIdaraId = safeIdaraId;
            ViewBag.CrudEntryData = safeEntryData;
            ViewBag.CrudHostName = safeHostName;
            // Compute last-updated date from latest history entry
            if (historyList.Count > 0)
            {
                var lastEntry = historyList[^1];
                var lastUpdated = lastEntry.GetValueOrDefault("actionDate")?.ToString();
                if (!string.IsNullOrWhiteSpace(lastUpdated))
                {
                    ticketRow["lastUpdated"] = lastUpdated;
                }
            }

            // Build TicketDetails data
            var ticketDetailsData = BuildTicketDetailsData(
                ticketRow,
                statusCode,
                childList,
                pauseList,
                ConvertTableToDictionaryList(qualityReviewTable),
                ConvertTableToDictionaryList(clarificationRequestsTable));

            // Build action forms
            var actions = BuildTicketActions(
                statusCode,
                pauseReasonOptions,
                arbitrationReasonOptions,
                actionPriorityOptions,
                actionClassOptions,
                clarificationReasonOptions,
                clarificationTargetDsdOptions,
                canAssignTicket,
                canStartWork,
                canResolveTicket,
                canPauseTicket,
                canResumeTicket,
                canRaiseArbitration,
                canCreateChildTicket,
                canRequestClarification,
                canRespondClarification,
                openClarificationRequestId?.ToString(),
                ticketId.ToString(),
                safeIdaraId,
                safeEntryData,
                safeHostName,
                ticketDetailsRedirectUrl,
                ticketRow);

            var page = new SmartPageViewModel
            {
                PageTitle = "تفاصيل التذكرة",
                PanelTitle = "تفاصيل التذكرة",
                PanelIcon = "fa fa-ticket",
                Form = searchForm,
                // SLA Panel
                SlaPanel = BuildSlaPanelConfig(ticketRow),
                // Ticket Timeline
                TicketTimeline = BuildTicketTimelineConfig(historyList),
                // Ticket Details Data
                TicketDetails = ticketDetailsData,
                // Ticket Actions
                TicketActions = actions
            };

            return View("TicketDetails", page);
        }

        #region TicketDetails Component Builders

        private SlaPanelConfig? BuildSlaPanelConfig(Dictionary<string, object?> ticketRow)
        {
            var elapsedMinutes = ticketRow.GetValueOrDefault("slaElapsedMinutes")?.ToString();
            var targetMinutes = ticketRow.GetValueOrDefault("slaTargetMinutes")?.ToString();
            var isBreached = ticketRow.GetValueOrDefault("slaIsBreached")?.ToString();

            if (string.IsNullOrWhiteSpace(elapsedMinutes) || string.IsNullOrWhiteSpace(targetMinutes))
                return null;

            int elapsed = int.TryParse(elapsedMinutes, out var el) ? el : 0;
            int target = int.TryParse(targetMinutes, out var tg) ? tg : 0;
            bool breached = isBreached == "True" || isBreached == "1";

            return new SlaPanelConfig
            {
                Title = "حالة مستوى الخدمة",
                Icon = "fa-clock",
                ResponseTimeMinutes = target / 60,
                ResolutionTimeMinutes = target / 60,
                AchievedPercentage = target > 0 ? Math.Min(100, Math.Round((decimal)elapsed / target * 100, 1)) : 0m,
                ShowDetails = true,
                ColorScheme = breached ? "red" : "green"
            };
        }

        private TicketTimelineConfig BuildTicketTimelineConfig(List<Dictionary<string, object?>> historyList)
        {
            var events = new List<TimelineEvent>();
            foreach (var h in historyList)
            {
                events.Add(new TimelineEvent
                {
                    ActionCode = h.GetValueOrDefault("actionTypeCode")?.ToString(),
                    ActionNameAr = h.GetValueOrDefault("actionNameAr")?.ToString(),
                    NewStatusCode = h.GetValueOrDefault("newStatusCode")?.ToString(),
                    NewStatusName_A = h.GetValueOrDefault("newStatusName_A")?.ToString(),
                    Notes = h.GetValueOrDefault("notes")?.ToString(),
                    PerformerName = h.GetValueOrDefault("performerName")?.ToString(),
                    ActionDate = h.GetValueOrDefault("actionDate")?.ToString() is { Length: > 0 } ad
                        ? DateTime.Parse(ad)
                        : (DateTime?)null
                });
            }

            return new TicketTimelineConfig
            {
                Title = "سجل المتابعة",
                Events = events,
                ShowEmptyState = true,
                EmptyStateText = "لا توجد سجلات متابعة متاحة لهذه التذكرة."
            };
        }

        private TicketDetailsData BuildTicketDetailsData(
            Dictionary<string, object?> ticketRow,
            string statusCode,
            List<Dictionary<string, object?>> childList,
            List<Dictionary<string, object?>> pauseList,
            List<Dictionary<string, object?>> qualityReviews,
            List<Dictionary<string, object?>> clarificationRequests)
        {
            var data = new TicketDetailsData
            {
                TicketId = GetStringValue(ticketRow, "ticketID"),
                TicketNo = GetStringValue(ticketRow, "ticketNo"),
                Title = GetStringValue(ticketRow, "title"),
                Description = GetStringValue(ticketRow, "description_", "description"),
                StatusCode = statusCode,
                StatusName = GetStringValue(ticketRow, "ticketStatusName_A", "ticketStatusName_E", "statusName"),
                PriorityCode = GetStringValue(ticketRow, "priorityCode"),
                PriorityName = GetStringValue(ticketRow, "priorityName_A", "priorityName_E", "priorityName"),
                IsBlocked = ToBoolean(ticketRow.GetValueOrDefault("isParentBlocked")),
                ServiceName = GetStringValue(ticketRow, "serviceName_A", "serviceName_E", "serviceName"),
                RequesterName = GetStringValue(ticketRow, "requesterName"),
                RequesterTypeName = GetStringValue(ticketRow, "requesterTypeName_A", "requesterTypeName_E", "requesterTypeName"),
                AssignedUserName = GetStringValue(ticketRow, "assignedUserName") ?? "--",
                TicketClassName = GetStringValue(ticketRow, "ticketClassName_A", "ticketClassName_E", "ticketClassName"),
                CurrentDsdId = GetStringValue(ticketRow, "currentDSDID_FK"),
                EntryDate = GetStringValue(ticketRow, "entryDate"),
                LastUpdated = GetStringValue(ticketRow, "lastUpdated"),
                OperationalResolutionDate = GetStringValue(ticketRow, "operationalResolutionDate"),
                FinalClosureDate = GetStringValue(ticketRow, "finalClosureDate"),
                BackLinkUrl = Url.Action("TicketList", "Ticket"),
                RequiresQualityReview = ToBoolean(ticketRow.GetValueOrDefault("requiresQualityReview")),
                LocationBuildingNo = GetStringValue(ticketRow, "locationBuildingNo"),
                LocationUnitNo = GetStringValue(ticketRow, "locationUnitNo"),
                LocationArea = GetStringValue(ticketRow, "locationArea"),
                SlaElapsedMinutes = int.TryParse(ticketRow.GetValueOrDefault("slaElapsedMinutes")?.ToString(), out var slaEl) ? slaEl : null,
                SlaTargetMinutes = int.TryParse(ticketRow.GetValueOrDefault("slaTargetMinutes")?.ToString(), out var slaTarget) ? slaTarget : null,
                SlaIsBreached = ToBoolean(ticketRow.GetValueOrDefault("slaIsBreached"))
            };

            // Related Tickets
            data.RelatedTickets = childList.Select(c => new TicketRelatedItem
            {
                TicketId = GetStringValue(c, "ticketID"),
                TicketNo = GetStringValue(c, "ticketNo"),
                Title = GetStringValue(c, "title"),
                StatusCode = GetStringValue(c, "statusCode", "ticketStatusCode"),
                StatusName = GetStringValue(c, "statusName", "ticketStatusName_A", "ticketStatusName_E"),
                PriorityName = GetStringValue(c, "priorityName", "priorityName_A", "priorityName_E")
            }).ToList();

            // Pause Sessions
            data.PauseSessions = pauseList.Select(p => new TicketPauseItem
            {
                ReasonName = GetStringValue(p, "pauseReasonName", "pauseReasonName_A", "pauseReasonName_E"),
                Notes = GetStringValue(p, "pauseNotes"),
                Start = GetStringValue(p, "pauseStart"),
                End = GetStringValue(p, "pauseEnd"),
                IsActive = !string.Equals(GetStringValue(p, "ticketPauseSessionActive"), "0", StringComparison.Ordinal)
            }).ToList();

            // Quality Reviews
            data.QualityReviews = qualityReviews.Select(q => new TicketQualityItem
            {
                ResultName = GetStringValue(q, "qualityReviewResultName", "qualityReviewResultName_A", "qualityReviewResultName_E"),
                ResultCode = GetStringValue(q, "qualityReviewResultCode"),
                Notes = GetStringValue(q, "reviewNotes"),
                ReviewerName = GetStringValue(q, "reviewerName"),
                Finalized = ToBoolean(q.GetValueOrDefault("finalized")),
                ReviewDate = GetStringValue(q, "entryDate")
            }).ToList();

            // Clarification Requests
            data.ClarificationRequests = clarificationRequests.Select(c => new TicketClarificationItem
            {
                RequestId = GetStringValue(c, "clarificationRequestID", "clarificationRequestId"),
                ReasonName = GetStringValue(c, "clarificationReasonName_A", "clarificationReasonName_E", "clarificationReasonName"),
                RequestNotes = GetStringValue(c, "requestNotes"),
                RequestDate = GetStringValue(c, "entryDate", "requestDate"),
                Status = GetStringValue(c, "clarificationStatus"),
                TargetDsdName = GetStringValue(c, "targetDSDName_A", "targetDSDName_E")
            }).ToList();

            // Ticket Info
            data.TicketInfo = new List<TicketInfoItem>
            {
                new() { Label = "الخدمة", Value = data.ServiceName },
                new() { Label = "مقدم الطلب", Value = data.RequesterName },
                new() { Label = "نوع مقدم الطلب", Value = data.RequesterTypeName },
                new() { Label = "المكلف بالعمل", Value = string.IsNullOrWhiteSpace(data.AssignedUserName) || data.AssignedUserName == "--" ? "غير معين" : data.AssignedUserName, Icon = data.AssignedUserName != "--" ? "fa-solid fa-user" : null },
                new() { Label = "التصنيف", Value = data.TicketClassName },
                new() { Label = "القسم", Value = string.IsNullOrWhiteSpace(data.CurrentDsdId) ? null : $"قسم #{data.CurrentDsdId}" },
                new() { Label = "الفرع", Value = data.LocationBuildingNo },
                new() { Label = "الوحدة", Value = data.LocationUnitNo },
                new() { Label = "الطابور الحالي", Value = data.ServiceName },
                new() { Label = "تاريخ الإنشاء", Value = data.EntryDate }
            };

            return data;
        }

        private static string? GetStringValue(Dictionary<string, object?> row, params string[] keys)
        {
            foreach (var key in keys)
            {
                if (!row.TryGetValue(key, out var value) || value == null)
                    continue;

                var text = value.ToString();
                if (!string.IsNullOrWhiteSpace(text))
                    return text;
            }

            return null;
        }

        private static bool ToBoolean(object? value)
        {
            var text = value?.ToString();
            return string.Equals(text, "1", StringComparison.Ordinal)
                || string.Equals(text, "true", StringComparison.OrdinalIgnoreCase);
        }

        private List<TicketAction> BuildTicketActions(
            string statusCode,
            List<OptionItem> pauseReasonOptions,
            List<OptionItem> arbitrationReasonOptions,
            List<OptionItem> actionPriorityOptions,
            List<OptionItem> actionClassOptions,
            List<OptionItem> clarificationReasonOptions,
            List<OptionItem> clarificationTargetDsdOptions,
            bool canAssignTicket,
            bool canStartWork,
            bool canResolveTicket,
            bool canPauseTicket,
            bool canResumeTicket,
            bool canRaiseArbitration,
            bool canCreateChildTicket,
            bool canRequestClarification,
            bool canRespondClarification,
            string? openClarificationRequestId,
            string ticketId,
            string crudIdaraId,
            string crudEntryData,
            string crudHostName,
            string redirectUrl,
            Dictionary<string, object?> header)
        {
            var actions = new List<TicketAction>();

            // PAUSE - IN_PROGRESS or CLARIFICATION
            if (canPauseTicket && (statusCode == "IN_PROGRESS" || statusCode == "CLARIFICATION"))
            {
                var pauseFields = new List<FieldConfig>
                {
                    new() { Name = "pageName_", Type = "hidden", Value = "TicketDetails" },
                    new() { Name = "ActionType", Type = "hidden", Value = "PAUSE_TICKET" },
                    new() { Name = "idaraID", Type = "hidden", Value = crudIdaraId },
                    new() { Name = "entrydata", Type = "hidden", Value = crudEntryData },
                    new() { Name = "hostname", Type = "hidden", Value = crudHostName },
                    new() { Name = "redirectUrl", Type = "hidden", Value = redirectUrl },
                    new() { Name = "p01", Type = "hidden", Value = ticketId }
                };

                if (pauseReasonOptions.Count > 0)
                {
                    pauseFields.Add(new FieldConfig
                    {
                        Label = "السبب",
                        Name = "p02",
                        Type = "select",
                        Options = pauseReasonOptions,
                        ColCss = "12",
                        Select2 = true
                    });
                }

                pauseFields.Add(new FieldConfig
                {
                    Label = "ملاحظات",
                    Name = "p03",
                    Type = "text",
                    ColCss = "12",
                    Placeholder = "ملاحظات اختيارية"
                });

                actions.Add(new TicketAction
                {
                    Code = "PAUSE_TICKET",
                    Label = "إيقاف مؤقت",
                    Icon = "fa-solid fa-pause",
                    Color = "warning",
                    Title = "إيقاف مؤقت",
                    ShowForStatuses = new() { "IN_PROGRESS", "CLARIFICATION" },
                    Form = new FormConfig
                    {
                        FormId = "pauseTicketForm",
                        Method = "post",
                        ActionUrl = "/crud/insert",
                        Fields = pauseFields,
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" },
                            new() { Text = "إيقاف", Type = "submit", Color = "warning", Icon = "fa-solid fa-pause" }
                        }
                    }
                });
            }

            // RESUME - PAUSED
            if (canResumeTicket && statusCode == "PAUSED")
            {
                actions.Add(new TicketAction
                {
                    Code = "RESUME_TICKET",
                    Label = "استئناف",
                    Icon = "fa-solid fa-play",
                    Color = "success",
                    Title = "استئناف العمل",
                    ShowForStatuses = new() { "PAUSED" },
                    Form = new FormConfig
                    {
                        FormId = "resumeTicketForm",
                        Method = "post",
                        ActionUrl = "/crud/insert",
                        Fields = new List<FieldConfig>
                        {
                            new() { Name = "pageName_", Type = "hidden", Value = "TicketDetails" },
                            new() { Name = "ActionType", Type = "hidden", Value = "RESUME_TICKET" },
                            new() { Name = "idaraID", Type = "hidden", Value = crudIdaraId },
                            new() { Name = "entrydata", Type = "hidden", Value = crudEntryData },
                            new() { Name = "hostname", Type = "hidden", Value = crudHostName },
                            new() { Name = "redirectUrl", Type = "hidden", Value = redirectUrl },
                            new() { Name = "p01", Type = "hidden", Value = ticketId },
                            new() { Label = "ملاحظات", Name = "p02", Type = "text", ColCss = "12", Placeholder = "ملاحظات اختيارية" }
                        },
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" },
                            new() { Text = "استئناف", Type = "submit", Color = "success", Icon = "fa-solid fa-play" }
                        }
                    }
                });
            }

            // ASSIGN - NEW
            if (canAssignTicket && statusCode == "NEW")
            {
                actions.Add(new TicketAction
                {
                    Code = "ASSIGN_TICKET",
                    Label = "تعيين",
                    Icon = "fa-solid fa-user-plus",
                    Color = "primary",
                    Title = "تعيين التذكرة",
                    ShowForStatuses = new() { "NEW" },
                    Form = new FormConfig
                    {
                        FormId = "assignTicketForm",
                        Method = "post",
                        ActionUrl = "/crud/insert",
                        Fields = new List<FieldConfig>
                        {
                            new() { Name = "pageName_", Type = "hidden", Value = "TicketDetails" },
                            new() { Name = "ActionType", Type = "hidden", Value = "ASSIGN_TICKET" },
                            new() { Name = "idaraID", Type = "hidden", Value = crudIdaraId },
                            new() { Name = "entrydata", Type = "hidden", Value = crudEntryData },
                            new() { Name = "hostname", Type = "hidden", Value = crudHostName },
                            new() { Name = "redirectUrl", Type = "hidden", Value = redirectUrl },
                            new() { Name = "p01", Type = "hidden", Value = ticketId },
                            new() { Label = "المستخدم", Name = "p02", Type = "text", ColCss = "12", Placeholder = "اسم المستخدم أو رقمه" }
                        },
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" },
                            new() { Text = "تعيين", Type = "submit", Color = "primary", Icon = "fa-solid fa-user-plus" }
                        }
                    }
                });
            }

            // START WORK - ASSIGNED or REOPENED
            if (canStartWork && (statusCode == "ASSIGNED" || statusCode == "REOPENED"))
            {
                actions.Add(new TicketAction
                {
                    Code = "START_WORK",
                    Label = "بدء العمل",
                    Icon = "fa-solid fa-play",
                    Color = "success",
                    Title = "بدء العمل",
                    ShowForStatuses = new() { "ASSIGNED", "REOPENED" },
                    Form = new FormConfig
                    {
                        FormId = "startWorkForm",
                        Method = "post",
                        ActionUrl = "/crud/insert",
                        Fields = new List<FieldConfig>
                        {
                            new() { Name = "pageName_", Type = "hidden", Value = "TicketDetails" },
                            new() { Name = "ActionType", Type = "hidden", Value = "START_WORK" },
                            new() { Name = "idaraID", Type = "hidden", Value = crudIdaraId },
                            new() { Name = "entrydata", Type = "hidden", Value = crudEntryData },
                            new() { Name = "hostname", Type = "hidden", Value = crudHostName },
                            new() { Name = "redirectUrl", Type = "hidden", Value = redirectUrl },
                            new() { Name = "p01", Type = "hidden", Value = ticketId },
                            new() { Label = "ملاحظات", Name = "p02", Type = "text", ColCss = "12", Placeholder = "ملاحظات اختيارية" }
                        },
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" },
                            new() { Text = "بدء العمل", Type = "submit", Color = "success", Icon = "fa-solid fa-play" }
                        }
                    }
                });
            }

            // RESOLVE - IN_PROGRESS or CLARIFICATION
            if (canResolveTicket && (statusCode == "IN_PROGRESS" || statusCode == "CLARIFICATION"))
            {
                actions.Add(new TicketAction
                {
                    Code = "RESOLVE_TICKET",
                    Label = "حل",
                    Icon = "fa-solid fa-check",
                    Color = "success",
                    Title = "حل التذكرة",
                    ShowForStatuses = new() { "IN_PROGRESS", "CLARIFICATION" },
                    Form = new FormConfig
                    {
                        FormId = "resolveTicketForm",
                        Method = "post",
                        ActionUrl = "/crud/insert",
                        Fields = new List<FieldConfig>
                        {
                            new() { Name = "pageName_", Type = "hidden", Value = "TicketDetails" },
                            new() { Name = "ActionType", Type = "hidden", Value = "RESOLVE_TICKET" },
                            new() { Name = "idaraID", Type = "hidden", Value = crudIdaraId },
                            new() { Name = "entrydata", Type = "hidden", Value = crudEntryData },
                            new() { Name = "hostname", Type = "hidden", Value = crudHostName },
                            new() { Name = "redirectUrl", Type = "hidden", Value = redirectUrl },
                            new() { Name = "p01", Type = "hidden", Value = ticketId },
                            new() { Label = "ملاحظات", Name = "p02", Type = "textarea", ColCss = "12", 
                                //Rows = 3,
                                Placeholder = "ملاحظات الحل" }
                        },
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" },
                            new() { Text = "حل", Type = "submit", Color = "success", Icon = "fa-solid fa-check" }
                        }
                    }
                });
            }

            // CREATE CHILD TICKET - IN_PROGRESS or CLARIFICATION
            if (canCreateChildTicket && (statusCode == "IN_PROGRESS" || statusCode == "CLARIFICATION"))
            {
                var childFields = new List<FieldConfig>
                {
                    new() { Name = "pageName_", Type = "hidden", Value = "TicketDetails" },
                    new() { Name = "ActionType", Type = "hidden", Value = "CREATE_CHILD_TICKET" },
                    new() { Name = "idaraID", Type = "hidden", Value = crudIdaraId },
                    new() { Name = "entrydata", Type = "hidden", Value = crudEntryData },
                    new() { Name = "hostname", Type = "hidden", Value = crudHostName },
                    new() { Name = "redirectUrl", Type = "hidden", Value = redirectUrl },
                    new() { Name = "p01", Type = "hidden", Value = ticketId },
                    new() { Name = "p02", Type = "hidden", Value = header.GetValueOrDefault("serviceID_FK")?.ToString() ?? "" },
                    new() { Name = "p04", Type = "hidden", Value = "2" },
                    new() { Name = "p10", Type = "hidden", Value = header.GetValueOrDefault("currentDSDID_FK")?.ToString() ?? "" },
                    new() { Label = "العنوان", Name = "p07", Type = "text", Required = true, ColCss = "12", Placeholder = "عنوان التذكرة الفرعية" },
                    new() { Label = "الوصف", Name = "p08", Type = "text", ColCss = "12", Placeholder = "وصف اختياري" }
                };

                if (actionPriorityOptions.Count > 0)
                {
                    childFields.Add(new FieldConfig
                    {
                        Label = "الأولوية",
                        Name = "p09",
                        Type = "select",
                        Options = actionPriorityOptions,
                        ColCss = "6",
                        Select2 = true
                    });
                }

                if (actionClassOptions.Count > 0)
                {
                    childFields.Add(new FieldConfig
                    {
                        Label = "الفئة",
                        Name = "p03",
                        Type = "select",
                        Options = actionClassOptions,
                        ColCss = "6",
                        Select2 = true
                    });
                }

                actions.Add(new TicketAction
                {
                    Code = "CREATE_CHILD_TICKET",
                    Label = "إنشاء تذكرة فرعية",
                    Icon = "fa-solid fa-plus",
                    Color = "secondary",
                    Title = "إنشاء تذكرة فرعية",
                    ShowForStatuses = new() { "IN_PROGRESS", "CLARIFICATION" },
                    Form = new FormConfig
                    {
                        FormId = "childTicketForm",
                        Method = "post",
                        ActionUrl = "/crud/insert",
                        Fields = childFields,
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" },
                            new() { Text = "إنشاء", Type = "submit", Color = "secondary", Icon = "fa-solid fa-plus" }
                        }
                    }
                });
            }

            // REQUEST CLARIFICATION - NOT PAUSED, CLARIFICATION, RESOLVED, CLOSED, REJECTED
            if (canRequestClarification && statusCode != "PAUSED" && statusCode != "CLARIFICATION" && statusCode != "RESOLVED" && statusCode != "CLOSED" && statusCode != "REJECTED")
            {
                var clarificationFields = new List<FieldConfig>
                {
                    new() { Name = "pageName_", Type = "hidden", Value = "TicketDetails" },
                    new() { Name = "ActionType", Type = "hidden", Value = "REQUEST_CLARIFICATION" },
                    new() { Name = "idaraID", Type = "hidden", Value = crudIdaraId },
                    new() { Name = "entrydata", Type = "hidden", Value = crudEntryData },
                    new() { Name = "hostname", Type = "hidden", Value = crudHostName },
                    new() { Name = "redirectUrl", Type = "hidden", Value = redirectUrl },
                    new() { Name = "p01", Type = "hidden", Value = ticketId },
                    new() { Name = "p02", Type = "hidden", Value = "" }
                };

                if (clarificationTargetDsdOptions.Count > 0)
                {
                    clarificationFields.Add(new FieldConfig
                    {
                        Label = "الجهة المطلوب منها التوضيح",
                        Name = "p03",
                        Type = "select",
                        Options = clarificationTargetDsdOptions,
                        Required = true,
                        ColCss = "12",
                        Select2 = true
                    });
                }

                if (clarificationReasonOptions.Count > 0)
                {
                    clarificationFields.Add(new FieldConfig
                    {
                        Label = "سبب طلب التوضيح",
                        Name = "p04",
                        Type = "select",
                        Options = clarificationReasonOptions,
                        Required = true,
                        ColCss = "12",
                        Select2 = true
                    });
                }

                clarificationFields.Add(new FieldConfig
                {
                    Label = "ملاحظات الطلب",
                    Name = "p05",
                    Type = "textarea",
                    Required = true,
                    ColCss = "12",
                    //Rows = 3,
                    Placeholder = "اكتب تفاصيل التوضيح المطلوب"
                });

                actions.Add(new TicketAction
                {
                    Code = "REQUEST_CLARIFICATION",
                    Label = "طلب توضيح",
                    Icon = "fa-solid fa-circle-question",
                    Color = "warning",
                    Title = "طلب توضيح",
                    Form = new FormConfig
                    {
                        FormId = "requestClarificationForm",
                        Method = "post",
                        ActionUrl = "/crud/insert",
                        Fields = clarificationFields,
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" },
                            new() { Text = "إرسال طلب", Type = "submit", Color = "warning", Icon = "fa-solid fa-question" }
                        }
                    }
                });
            }

            // RESPOND CLARIFICATION - whenever an open request exists
            if (canRespondClarification && !string.IsNullOrEmpty(openClarificationRequestId))
            {
                actions.Add(new TicketAction
                {
                    Code = "RESPOND_CLARIFICATION",
                    Label = "الرد على التوضيح",
                    Icon = "fa-solid fa-reply",
                    Color = "primary",
                    Title = "الرد على التوضيح",
                    Form = new FormConfig
                    {
                        FormId = "respondClarificationForm",
                        Method = "post",
                        ActionUrl = "/crud/insert",
                        Fields = new List<FieldConfig>
                        {
                            new() { Name = "pageName_", Type = "hidden", Value = "TicketDetails" },
                            new() { Name = "ActionType", Type = "hidden", Value = "RESPOND_CLARIFICATION" },
                            new() { Name = "idaraID", Type = "hidden", Value = crudIdaraId },
                            new() { Name = "entrydata", Type = "hidden", Value = crudEntryData },
                            new() { Name = "hostname", Type = "hidden", Value = crudHostName },
                            new() { Name = "redirectUrl", Type = "hidden", Value = redirectUrl },
                            new() { Name = "p01", Type = "hidden", Value = openClarificationRequestId },
                            new() { Label = "الرد", Name = "p02", Type = "textarea", Required = true, ColCss = "12",
                                Placeholder = "اكتب الرد على طلب التوضيح" }
                        },
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" },
                            new() { Text = "إرسال الرد", Type = "submit", Color = "primary", Icon = "fa-solid fa-reply" }
                        }
                    }
                });
            }

            // RAISE ARBITRATION - IN_PROGRESS or CLARIFICATION
            if (canRaiseArbitration && (statusCode == "IN_PROGRESS" || statusCode == "CLARIFICATION"))
            {
                var arbitrationFields = new List<FieldConfig>
                {
                    new() { Name = "pageName_", Type = "hidden", Value = "TicketDetails" },
                    new() { Name = "ActionType", Type = "hidden", Value = "RAISE_ARBITRATION" },
                    new() { Name = "idaraID", Type = "hidden", Value = crudIdaraId },
                    new() { Name = "entrydata", Type = "hidden", Value = crudEntryData },
                    new() { Name = "hostname", Type = "hidden", Value = crudHostName },
                    new() { Name = "redirectUrl", Type = "hidden", Value = redirectUrl },
                    new() { Name = "p01", Type = "hidden", Value = ticketId }
                };

                if (arbitrationReasonOptions.Count > 0)
                {
                    arbitrationFields.Add(new FieldConfig
                    {
                        Label = "السبب",
                        Name = "p02",
                        Type = "select",
                        Options = arbitrationReasonOptions,
                        ColCss = "12",
                        Select2 = true
                    });
                }

                arbitrationFields.Add(new FieldConfig
                {
                    Label = "ملاحظات",
                    Name = "p04",
                    Type = "text",
                    ColCss = "12",
                    Placeholder = "ملاحظات اختيارية"
                });

                actions.Add(new TicketAction
                {
                    Code = "RAISE_ARBITRATION",
                    Label = "رفع تحكيم",
                    Icon = "fa-solid fa-gavel",
                    Color = "danger",
                    Title = "رفع تحكيم",
                    ShowForStatuses = new() { "IN_PROGRESS", "CLARIFICATION" },
                    Form = new FormConfig
                    {
                        FormId = "arbitrationForm",
                        Method = "post",
                        ActionUrl = "/crud/insert",
                        Fields = arbitrationFields,
                        Buttons = new List<FormButtonConfig>
                        {
                            new() { Text = "إلغاء", Type = "button", Color = "secondary", OnClickJs = "this.closest('.sf-modal').__x.$data.closeModal();" },
                            new() { Text = "رفع تحكيم", Type = "submit", Color = "danger", Icon = "fa-solid fa-gavel" }
                        }
                    }
                });
            }

            return actions;
        }

        #endregion

        private async Task<int?> TryGetLatestTicketIdAsync()
        {
            try
            {
                DataSet dataSet = await _mastersServies.GetDataLoadDataSetAsync(
                    "TicketList",
                    IdaraId,
                    usersId,
                    HostName,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null);

                var table = ResolveUsableTable(dataSet, "ticketID", "ticketNo");
                if (table == null || table.Rows.Count == 0)
                    return null;

                return int.TryParse(table.Rows[0]["ticketID"]?.ToString(), out var ticketId)
                    ? ticketId
                    : null;
            }
            catch
            {
                return null;
            }
        }

        private async Task<DataTable?> LoadTicketDataTableAsync(
            string pageName,
            int ticketId,
            params string[] expectedColumns)
        {
            try
            {
                DataSet dataSet = await _mastersServies.GetDataLoadDataSetAsync(
                    pageName, IdaraId, usersId, HostName, ticketId.ToString());

                return ResolveUsableTable(dataSet, expectedColumns);
            }
            catch
            {
                return null;
            }
        }

        private static DataTable? ResolveUsableTable(DataSet? dataSet, params string[] expectedColumns)
        {
            if (dataSet == null)
                return null;

            if (dataSet.Tables.Count > 1 && IsUsableTable(dataSet.Tables[1], expectedColumns))
                return dataSet.Tables[1];

            if (dataSet.Tables.Count > 0 && IsUsableTable(dataSet.Tables[0], expectedColumns))
                return dataSet.Tables[0];

            return null;
        }

        private static DataTable? ResolveUsableTable(DataTable? table, params string[] expectedColumns)
        {
            return IsUsableTable(table, expectedColumns) ? table : null;
        }

        private static bool IsUsableTable(DataTable? table, params string[] expectedColumns)
        {
            return table != null
                && !IsGatewayErrorTable(table)
                && expectedColumns.Any(table.Columns.Contains);
        }

        private static bool IsGatewayErrorTable(DataTable? table)
        {
            return table != null
                && table.Columns.Contains("IsSuccessful")
                && table.Columns.Contains("Message_");
        }

        private static List<Dictionary<string, object?>> ConvertTableToDictionaryList(DataTable? table)
        {
            var items = new List<Dictionary<string, object?>>();
            if (table == null)
                return items;

            foreach (DataRow row in table.Rows)
            {
                var item = new Dictionary<string, object?>();
                foreach (DataColumn column in table.Columns)
                {
                    var rawValue = row[column] == DBNull.Value ? null : row[column];
                    item[column.ColumnName] = rawValue is string textValue
                        ? NormalizeResidentText(textValue)
                        : rawValue;
                }
                items.Add(item);
            }

            return items;
        }

        [HttpPost]
        public async Task<IActionResult> UploadAttachment(int id, IFormFile? attachmentFile)
        {
            if (!InitPageContext(out var redirect))
                return redirect!;

            if (attachmentFile == null || attachmentFile.Length == 0)
            {
                TempData["Warning"] = "لم يتم اختيار ملف";
                return RedirectToAction("TicketDetails", new { id });
            }

            const long maxFileSize = 10 * 1024 * 1024; // 10 MB
            if (attachmentFile.Length > maxFileSize)
            {
                TempData["Warning"] = "حجم الملف يتجاوز الحد المسموح (10 ميجابايت)";
                return RedirectToAction("TicketDetails", new { id });
            }

            var allowedExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx",
                ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".webp",
                ".txt", ".csv", ".zip", ".rar", ".7z", ".msg"
            };
            var ext = Path.GetExtension(attachmentFile.FileName);
            if (string.IsNullOrEmpty(ext) || !allowedExtensions.Contains(ext))
            {
                TempData["Warning"] = "نوع الملف غير مسموح به";
                return RedirectToAction("TicketDetails", new { id });
            }

            var uploadsDir = Path.Combine(_env.WebRootPath, "uploads", "tickets", id.ToString());
            Directory.CreateDirectory(uploadsDir);

            var storedName = $"{Guid.NewGuid()}{Path.GetExtension(attachmentFile.FileName)}";
            var filePath = Path.Combine(uploadsDir, storedName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await attachmentFile.CopyToAsync(stream);
            }

            var relativePath = $"uploads/tickets/{id}/{storedName}";
            var attachmentType = Request.Form["p07"].ToString();

            var crudParams = new object?[]
            {
                "Tickets",
                "UPLOAD_ATTACHMENT",
                IdaraId,
                usersId,
                HostName,
                id.ToString(),
                attachmentFile.FileName,
                storedName,
                relativePath,
                attachmentFile.Length.ToString(),
                attachmentFile.ContentType,
                attachmentType
            };

            await _mastersServies.GetCrudDataSetAsync(crudParams);

            TempData["Success"] = "تم رفع المرفق بنجاح";
            return RedirectToAction("TicketDetails", new { id });
        }

        private async Task<List<OptionItem>> GetDDLAsync(string labelCol, string valueCol, string ddlType, string? pageNameOverride = null)
        {
            var result = new List<OptionItem>();
            var ddlResult = await _CrudController.GetDDLValues(
                labelCol, valueCol, ddlType, pageNameOverride ?? PageName, usersId, IdaraId, HostName
            ) as JsonResult;

            if (ddlResult?.Value != null)
            {
                var json = JsonSerializer.Serialize(ddlResult.Value);
                result = JsonSerializer.Deserialize<List<OptionItem>>(json) ?? new();
            }
            return result;
        }

        private SmartTableDsModel? BuildTableFromDS(DataSet? ds, string rowIdField, string panelTitle, TableToolbarConfig? toolbar = null)
        {
            DataTable? dt = (ds?.Tables?.Count ?? 0) > 1 ? ds!.Tables[1] : null;
            if (dt == null || dt.Columns.Count == 0) return null;

            var columns = new List<TableColumn>();
            var rows = new List<Dictionary<string, object?>>();

            foreach (DataColumn col in dt.Columns)
                columns.Add(new TableColumn { Field = col.ColumnName, Label = TranslateColumn(col.ColumnName) });

            foreach (DataRow dr in dt.Rows)
            {
                var dict = new Dictionary<string, object?>();
                foreach (DataColumn col in dt.Columns)
                    dict[col.ColumnName] = dr[col] == DBNull.Value ? null : dr[col];
                rows.Add(dict);
            }

            return new SmartTableDsModel
            {
                PanelTitle = panelTitle,
                Columns = columns,
                Rows = rows,
                RowIdField = rowIdField,
                Toolbar = toolbar ?? new TableToolbarConfig { ShowAdd = false, ShowEdit = false, ShowDelete = false }
            };
        }

        private async Task<SmartTableDsModel?> LoadSubTableAsync(string pageName, int? ticketId, string rowIdField, string panelTitle)
        {
            DataSet ds = await _mastersServies.GetDataLoadDataSetAsync(
                pageName, IdaraId, usersId, HostName, ticketId?.ToString()
            );
            return BuildTableFromDS(ds, rowIdField, panelTitle);
        }

        private static string TranslateColumn(string name) => name switch
        {
            "ticketHistoryID" => "رقم الحدث",
            "ticketID_FK" => "رقم التذكرة",
            "actionTypeCode" => "نوع الإجراء",
            "oldStatusID_FK" => "الحالة السابقة",
            "oldStatusCode" => "كود الحالة السابقة",
            "oldStatusName_E" => "الحالة السابقة",
            "newStatusID_FK" => "الحالة الجديدة",
            "newStatusCode" => "كود الحالة الجديدة",
            "newStatusName_E" => "الحالة الجديدة",
            "oldDSDID_FK" => "القسم السابق",
            "newDSDID_FK" => "القسم الجديد",
            "oldAssignedUserID" => "المستخدم السابق",
            "newAssignedUserID" => "المستخدم الجديد",
            "performerUserID" => "منفذ الإجراء",
            "notes" => "ملاحظات",
            "actionDate" => "تاريخ الإجراء",
            "ticketID" => "رقم التذكرة",
            "ticketNo" => "رقم التذكرة",
            "title" => "العنوان",
            "ticketStatusCode" => "الحالة",
            "ticketStatusName_E" => "الحالة",
            "priorityName_E" => "الأولوية",
            "entryDate" => "تاريخ الإنشاء",
            "ticketPauseSessionID" => "رقم الإيقاف",
            "pauseReasonName_A" => "سبب الإيقاف",
            "pauseReasonName_E" => "سبب الإيقاف",
            "relatedChildTicketID_FK" => "التذكرة الفرعية",
            "relatedArbitrationCaseID_FK" => "قضية التحكيم",
            "relatedClarificationRequestID_FK" => "طلب التوضيح",
            "pauseStart" => "بداية الإيقاف",
            "pauseEnd" => "نهاية الإيقاف",
            "slaPauseFlag" => "إيقاف SLA",
            "pauseNotes" => "ملاحظات الإيقاف",
            "ticketPauseSessionActive" => "نشط",
            "ticketSLAID" => "رقم SLA",
            "slaTypeCode" => "نوع SLA",
            "targetMinutes" => "الهدف (دقيقة)",
            "elapsedMinutes" => "المنقضي (دقيقة)",
            "remainingMinutes" => "المتبقي (دقيقة)",
            "isBreached" => "مخالف",
            "slaStartDate" => "تاريخ البداية",
            "slaStopDate" => "تاريخ الإيقاف",
            "slaCompletionDate" => "تاريخ الإنجاز",
            "ticketSLAActive" => "نشط",
            "qualityReviewID" => "رقم المراجعة",
            "reviewerUserID" => "المراجع",
            "reviewScope" => "نطاق المراجعة",
            "qualityReviewResultID_FK" => "رقم النتيجة",
            "qualityReviewResultCode" => "كود النتيجة",
            "qualityReviewResultName_A" => "النتيجة",
            "qualityReviewResultName_E" => "النتيجة",
            "reviewNotes" => "ملاحظات المراجعة",
            "returnToUserID" => "إرجاع إلى",
            "finalized" => "مُنهية",
            "arbitrationCaseID" => "رقم التحكيم",
            "raisedByUserID" => "مقدم التحكيم",
            "raisedFromDSDID_FK" => "القسم المقدم",
            "arbitrationReasonName_A" => "سبب التحكيم",
            "arbitrationReasonName_E" => "سبب التحكيم",
            "arbitratorDistributorID" => "المحكم",
            "arbitrationStatus" => "حالة التحكيم",
            "decisionType" => "نوع القرار",
            "decisionTargetDSDID_FK" => "القسم المستهدف",
            "decisionNotes" => "ملاحظات القرار",
            "decisionDate" => "تاريخ القرار",
            "ticketAttachmentID" => "رقم المرفق",
            "fileName" => "اسم الملف",
            "storedFileName" => "الاسم المخزن",
            "filePath" => "المسار",
            "fileSizeBytes" => "حجم الملف",
            "contentType" => "نوع المحتوى",
            "uploadedByUserID" => "رافع الملف",
            "attachmentType" => "نوع المرفق",
            "ticketAttachmentActive" => "نشط",
            _ => name
        };
    }
}
