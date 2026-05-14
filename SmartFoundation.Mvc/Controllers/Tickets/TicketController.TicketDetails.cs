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

            var ticketTable = ResolveUsableTable(ds, "ticketID", "ticketNo", "title");
            if (ticketTable == null || ticketTable.Rows.Count == 0)
            {
                ticketTable = await LoadTicketDetailsFallbackAsync(id.Value);
            }

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
            foreach (DataColumn col in ticketTable.Columns)
                ticketRow[col.ColumnName] = ticketTable.Rows[0][col] == DBNull.Value ? null : ticketTable.Rows[0][col];

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
                id.Value,
                LoadTicketHistoryFallbackAsync,
                "actionTypeCode",
                "actionDate");

            // ---- Audit trail (raw list for timeline rendering) ----
            var historyList = ConvertTableToDictionaryList(historyTable);
            ViewBag.AuditTrail = historyList;

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
                id.Value,
                LoadChildTicketsFallbackAsync,
                "ticketID",
                "ticketNo");
            var childList = ConvertTableToDictionaryList(childTable);
            ViewBag.ChildTickets = childList;

            // ---- Pause sessions (raw list) ----
            var pauseTable = await LoadTicketDataTableAsync(
                "PauseSessions",
                id.Value,
                LoadPauseSessionsFallbackAsync,
                "ticketPauseSessionID",
                "pauseStart");
            var pauseList = ConvertTableToDictionaryList(pauseTable);
            ViewBag.PauseSessions = pauseList;

            var qualityReviewTable = await LoadTicketDataTableAsync(
                "QualityReviews",
                id.Value,
                LoadQualityReviewsFallbackAsync,
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

            var clarificationRequestsTable = await LoadClarificationRequestsFallbackAsync(id.Value);
            ViewBag.ClarificationRequests = ConvertTableToDictionaryList(clarificationRequestsTable);

            long? openClarificationRequestId = null;
            if (canRespondClarification)
            {
                var openClarificationMap = await GetOpenClarificationRequestMapAsync(new[] { (long)id.Value });
                if (openClarificationMap.TryGetValue(id.Value, out var clarificationRequestId))
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
            ViewBag.CrudIdaraId = IdaraId;
            ViewBag.CrudEntryData = usersId;
            ViewBag.CrudHostName = HostName;
            ViewBag.TicketDetailsRedirectUrl = Url.Action(nameof(TicketDetails), "Ticket", new { id = id.Value });

            var page = new SmartPageViewModel
            {
                PageTitle = "تفاصيل التذكرة",
                PanelTitle = "تفاصيل التذكرة",
                PanelIcon = "fa fa-ticket"
            };

            return View("TicketDetails", page);
        }

        private async Task<int?> TryGetLatestTicketIdAsync()
        {
            const string sql = @"
SELECT TOP 1 [ticketID]
FROM [Tickets].[Ticket] t
OUTER APPLY (
        SELECT COUNT(1) AS [historyCount]
        FROM [Tickets].[TicketHistory] th
        WHERE th.[ticketID_FK] = t.[ticketID]
) historyAgg
OUTER APPLY (
        SELECT COUNT(1) AS [reviewCount]
        FROM [Tickets].[QualityReview] qr
        WHERE qr.[ticketID_FK] = t.[ticketID]
            AND qr.[qualityReviewActive] = 1
) reviewAgg
WHERE t.[ticketActive] = 1
    AND (t.[idaraID_FK] = @idaraID OR @idaraID IS NULL)
ORDER BY
            historyAgg.[historyCount] DESC
        , reviewAgg.[reviewCount] DESC
        , CASE WHEN t.[assignedUserID_FK] IS NULL THEN 0 ELSE 1 END DESC
        , CASE WHEN t.[operationalResolutionDate] IS NULL THEN 0 ELSE 1 END DESC
        , t.[ticketID] DESC;";

            var table = await ExecuteTicketDetailsQueryAsync(sql, ("@idaraID", ParseTicketDetailsNullableInt(IdaraId)));
            if (table.Rows.Count == 0)
                return null;

            return int.TryParse(table.Rows[0]["ticketID"]?.ToString(), out var ticketId)
                ? ticketId
                : null;
        }

        private async Task<DataTable?> LoadTicketDataTableAsync(
            string pageName,
            int ticketId,
            Func<int, Task<DataTable>> fallbackLoader,
            params string[] expectedColumns)
        {
            try
            {
                DataSet dataSet = await _mastersServies.GetDataLoadDataSetAsync(
                    pageName, IdaraId, usersId, HostName, ticketId.ToString());

                var gatewayTable = ResolveUsableTable(dataSet, expectedColumns);
                if (gatewayTable != null && gatewayTable.Rows.Count > 0)
                    return gatewayTable;
            }
            catch
            {
                // Direct SQL fallback is used when the live gateway route is missing or broken.
            }

            var fallbackTable = await fallbackLoader(ticketId);
            return ResolveUsableTable(fallbackTable, expectedColumns);
        }

        private async Task<DataTable> LoadTicketDetailsFallbackAsync(int ticketId)
        {
            const string sql = @"
SELECT TOP 1
      t.[ticketID]
    , t.[ticketNo]
        , t.[serviceID_FK]
    , COALESCE(NULLIF(svc.[serviceName_A], N''), svc.[serviceName_E]) AS [serviceName_A]
    , COALESCE(NULLIF(tc.[ticketClassName_A], N''), tc.[ticketClassName_E]) AS [ticketClassName_A]
    , COALESCE(NULLIF(rt.[requesterTypeName_A], N''), rt.[requesterTypeName_E]) AS [requesterTypeName_A]
    , COALESCE(NULLIF(requesterUser.[fullName], N''), NULLIF(requesterResident.[fullName], N''), N'--') AS [requesterName]
    , COALESCE(t.[title_A], t.[title]) AS [title]
    , COALESCE(t.[description_A], t.[description_]) AS [description_]
    , COALESCE(NULLIF(p.[priorityName_A], N''), p.[priorityName_E]) AS [priorityName_A]
    , p.[priorityCode]
    , ts.[ticketStatusCode]
    , COALESCE(NULLIF(ts.[ticketStatusName_A], N''), ts.[ticketStatusName_E]) AS [ticketStatusName_A]
    , COALESCE(NULLIF(assignedUser.[fullName], N''), N'--') AS [assignedUserName]
    , t.[locationBuildingNo]
    , t.[locationUnitNo]
    , COALESCE(t.[locationArea_A], t.[locationArea]) AS [locationArea]
    , t.[operationalResolutionDate]
    , t.[finalClosureDate]
    , t.[requiresQualityReview]
    , t.[isOtherService]
    , t.[isParentBlocked]
    , ISNULL(svc.[allowsChildTickets], 0) AS [allowsChildTickets]
    , t.[currentDSDID_FK]
    , t.[currentQueueDistributorID_FK]
    , t.[parentTicketID_FK]
    , t.[rootTicketID_FK]
    , sla.[elapsedMinutes] AS [slaElapsedMinutes]
    , sla.[targetMinutes] AS [slaTargetMinutes]
    , sla.[isBreached] AS [slaIsBreached]
    , sla.[slaTypeCode] AS [slaTypeCode]
    , t.[entryDate]
FROM [Tickets].[Ticket] t
LEFT JOIN [Tickets].[Service] svc ON t.[serviceID_FK] = svc.[serviceID]
LEFT JOIN [Tickets].[TicketClass] tc ON t.[ticketClassID_FK] = tc.[ticketClassID]
LEFT JOIN [Tickets].[RequesterType] rt ON t.[requesterTypeID_FK] = rt.[requesterTypeID]
LEFT JOIN [Tickets].[Priority] p ON t.[effectivePriorityID_FK] = p.[priorityID]
LEFT JOIN [Tickets].[TicketStatus] ts ON t.[ticketStatusID_FK] = ts.[ticketStatusID]
OUTER APPLY (
    SELECT TOP 1 LTRIM(RTRIM(
          ISNULL(CASE WHEN ud.[firstName_A] IS NULL OR ud.[firstName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[firstName_E] ELSE ud.[firstName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[secondName_A] IS NULL OR ud.[secondName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[secondName_E] ELSE ud.[secondName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[thirdName_A] IS NULL OR ud.[thirdName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[thirdName_E] ELSE ud.[thirdName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[lastName_A] IS NULL OR ud.[lastName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[lastName_E] ELSE ud.[lastName_A] END, N'')
    )) AS [fullName]
    FROM [dbo].[UsersDetails] ud
    WHERE ud.[usersID_FK] = t.[requesterUserID_FK]
    ORDER BY ud.[entryDate] DESC, ud.[usersDetailsID] DESC
) requesterUser
OUTER APPLY (
    SELECT TOP 1 COALESCE(NULLIF(r.[FullName_A], N''), N'--') AS [fullName]
    FROM [Housing].[V_GetFullResidentDetails] r
    WHERE r.[residentInfoID] = t.[requesterResidentID_FK]
) requesterResident
OUTER APPLY (
    SELECT TOP 1 LTRIM(RTRIM(
          ISNULL(CASE WHEN ud.[firstName_A] IS NULL OR ud.[firstName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[firstName_E] ELSE ud.[firstName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[secondName_A] IS NULL OR ud.[secondName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[secondName_E] ELSE ud.[secondName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[thirdName_A] IS NULL OR ud.[thirdName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[thirdName_E] ELSE ud.[thirdName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[lastName_A] IS NULL OR ud.[lastName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[lastName_E] ELSE ud.[lastName_A] END, N'')
    )) AS [fullName]
    FROM [dbo].[UsersDetails] ud
    WHERE ud.[usersID_FK] = t.[assignedUserID_FK]
    ORDER BY ud.[entryDate] DESC, ud.[usersDetailsID] DESC
) assignedUser
OUTER APPLY (
    SELECT TOP 1 sl.[elapsedMinutes], sl.[targetMinutes], sl.[isBreached], sl.[slaTypeCode]
    FROM [Tickets].[TicketSLA] sl
    WHERE sl.[ticketID_FK] = t.[ticketID]
      AND sl.[slaTypeCode] = N'RESOLUTION'
      AND sl.[ticketSLAActive] = 1
) sla
WHERE t.[ticketActive] = 1
  AND t.[ticketID] = @ticketID
  AND (t.[idaraID_FK] = @idaraID OR @idaraID IS NULL)
ORDER BY t.[ticketID] DESC;";

            return await ExecuteTicketDetailsQueryAsync(
                sql,
                ("@ticketID", ticketId),
                ("@idaraID", ParseTicketDetailsNullableInt(IdaraId)));
        }

        private async Task<DataTable> LoadTicketHistoryFallbackAsync(int ticketId)
        {
            const string sql = @"
SELECT
      th.[ticketHistoryID]
    , th.[ticketID_FK]
    , th.[actionTypeCode]
    , ts.[ticketStatusCode] AS [newStatusCode]
    , COALESCE(NULLIF(ts.[ticketStatusName_A], N''), ts.[ticketStatusName_E]) AS [newStatusName_A]
    , performerUser.[fullName] AS [performerName]
    , COALESCE(th.[notes_A], th.[notes]) AS [notes]
    , th.[actionDate]
FROM [Tickets].[TicketHistory] th
LEFT JOIN [Tickets].[TicketStatus] ts ON th.[newStatusID_FK] = ts.[ticketStatusID]
OUTER APPLY (
    SELECT TOP 1 LTRIM(RTRIM(
          ISNULL(CASE WHEN ud.[firstName_A] IS NULL OR ud.[firstName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[firstName_E] ELSE ud.[firstName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[secondName_A] IS NULL OR ud.[secondName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[secondName_E] ELSE ud.[secondName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[thirdName_A] IS NULL OR ud.[thirdName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[thirdName_E] ELSE ud.[thirdName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[lastName_A] IS NULL OR ud.[lastName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[lastName_E] ELSE ud.[lastName_A] END, N'')
      )) AS [fullName]
    FROM [dbo].[UsersDetails] ud
    WHERE ud.[usersID_FK] = th.[performerUserID]
    ORDER BY ud.[entryDate] DESC, ud.[usersDetailsID] DESC
) performerUser
WHERE th.[ticketID_FK] = @ticketID
ORDER BY th.[ticketHistoryID] ASC;";

            return await ExecuteTicketDetailsQueryAsync(sql, ("@ticketID", ticketId));
        }

        private async Task<DataTable> LoadChildTicketsFallbackAsync(int ticketId)
        {
            const string sql = @"
SELECT
      ct.[ticketID]
    , ct.[ticketNo]
    , COALESCE(ct.[title_A], ct.[title]) AS [title]
    , ts.[ticketStatusCode]
    , COALESCE(NULLIF(ts.[ticketStatusName_A], N''), ts.[ticketStatusName_E]) AS [ticketStatusName_A]
    , COALESCE(NULLIF(p.[priorityName_A], N''), p.[priorityName_E]) AS [priorityName_A]
    , ct.[entryDate]
FROM [Tickets].[Ticket] ct
LEFT JOIN [Tickets].[TicketStatus] ts ON ct.[ticketStatusID_FK] = ts.[ticketStatusID]
LEFT JOIN [Tickets].[Priority] p ON ct.[effectivePriorityID_FK] = p.[priorityID]
WHERE ct.[parentTicketID_FK] = @ticketID
  AND ct.[ticketActive] = 1
ORDER BY ct.[ticketID] DESC;";

            return await ExecuteTicketDetailsQueryAsync(sql, ("@ticketID", ticketId));
        }

        private async Task<DataTable> LoadPauseSessionsFallbackAsync(int ticketId)
        {
            const string sql = @"
SELECT
      ps.[ticketPauseSessionID]
    , COALESCE(NULLIF(pr.[pauseReasonName_A], N''), pr.[pauseReasonName_E]) AS [pauseReasonName_A]
    , ps.[relatedClarificationRequestID_FK]
    , ps.[pauseStart]
    , ps.[pauseEnd]
    , COALESCE(ps.[pauseNotes_A], ps.[pauseNotes]) AS [pauseNotes]
    , ps.[ticketPauseSessionActive]
FROM [Tickets].[TicketPauseSession] ps
LEFT JOIN [Tickets].[PauseReason] pr ON ps.[pauseReasonID_FK] = pr.[pauseReasonID]
WHERE ps.[ticketID_FK] = @ticketID
ORDER BY ps.[ticketPauseSessionID] DESC;";

            return await ExecuteTicketDetailsQueryAsync(sql, ("@ticketID", ticketId));
        }

                private async Task<DataTable> LoadQualityReviewsFallbackAsync(int ticketId)
                {
                        const string sql = @"
SELECT
            qr.[qualityReviewID]
        , COALESCE(NULLIF(qrr.[qualityReviewResultName_A], N''), qrr.[qualityReviewResultName_E]) AS [qualityReviewResultName_A]
        , qrr.[qualityReviewResultCode]
        , COALESCE(qr.[reviewNotes_A], qr.[reviewNotes]) AS [reviewNotes]
        , qr.[finalized]
        , qr.[entryDate]
        , reviewerUser.[fullName] AS [reviewerName]
FROM [Tickets].[QualityReview] qr
LEFT JOIN [Tickets].[QualityReviewResult] qrr ON qr.[qualityReviewResultID_FK] = qrr.[qualityReviewResultID]
OUTER APPLY (
        SELECT TOP 1 LTRIM(RTRIM(
                    ISNULL(CASE WHEN ud.[firstName_A] IS NULL OR ud.[firstName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[firstName_E] ELSE ud.[firstName_A] END, N'') + N' ' +
                    ISNULL(CASE WHEN ud.[secondName_A] IS NULL OR ud.[secondName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[secondName_E] ELSE ud.[secondName_A] END, N'') + N' ' +
                    ISNULL(CASE WHEN ud.[thirdName_A] IS NULL OR ud.[thirdName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[thirdName_E] ELSE ud.[thirdName_A] END, N'') + N' ' +
                    ISNULL(CASE WHEN ud.[lastName_A] IS NULL OR ud.[lastName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[lastName_E] ELSE ud.[lastName_A] END, N'')
            )) AS [fullName]
        FROM [dbo].[UsersDetails] ud
        WHERE ud.[usersID_FK] = qr.[reviewerUserID]
        ORDER BY ud.[entryDate] DESC, ud.[usersDetailsID] DESC
) reviewerUser
WHERE qr.[ticketID_FK] = @ticketID
    AND qr.[qualityReviewActive] = 1
ORDER BY qr.[qualityReviewID] DESC;";

                        return await ExecuteTicketDetailsQueryAsync(sql, ("@ticketID", ticketId));
                }

        private async Task<DataTable> ExecuteTicketDetailsQueryAsync(string sql, params (string Name, object? Value)[] parameters)
        {
            var dt = new DataTable();
            var connectionString = GetDefaultConnectionString();

            using var connection = new Microsoft.Data.SqlClient.SqlConnection(connectionString);
            await connection.OpenAsync();

            using var command = new Microsoft.Data.SqlClient.SqlCommand(sql, connection);
            foreach (var (name, value) in parameters)
            {
                command.Parameters.AddWithValue(name, value ?? DBNull.Value);
            }

            using var reader = await command.ExecuteReaderAsync();
            dt.Load(reader);
            return dt;
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

        private static int? ParseTicketDetailsNullableInt(string? value)
        {
            return int.TryParse(value, out var parsed) ? parsed : null;
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
