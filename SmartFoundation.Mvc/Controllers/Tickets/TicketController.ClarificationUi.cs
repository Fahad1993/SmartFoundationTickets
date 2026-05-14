using SmartFoundation.UI.ViewModels.SmartForm;
using System.Data;

namespace SmartFoundation.Mvc.Controllers.Tickets
{
    public partial class TicketController
    {
        private async Task<List<OptionItem>> GetClarificationReasonOptionsAsync(string? firstOption = "اختر سبب طلب التوضيح")
        {
            const string sql = @"
SELECT [clarificationReasonID], [clarificationReasonName_A], [clarificationReasonName_E]
FROM [Tickets].[ClarificationReason]
WHERE [clarificationReasonActive] = 1
ORDER BY [clarificationReasonID];";

            var table = await ExecuteTicketFallbackQueryAsync(sql);
            return BuildOptionItems(table, "clarificationReasonID", "clarificationReasonName_A", firstOption);
        }

        private async Task<Dictionary<long, long>> GetOpenClarificationRequestMapAsync(IEnumerable<long> ticketIds)
        {
            var ids = ticketIds
                .Where(id => id > 0)
                .Distinct()
                .ToList();

            if (ids.Count == 0)
                return new Dictionary<long, long>();

            var idList = string.Join(",", ids);
            var sql = $@"
SELECT [ticketID_FK], [clarificationRequestID]
FROM
(
    SELECT
          cr.[ticketID_FK]
        , cr.[clarificationRequestID]
        , ROW_NUMBER() OVER (
              PARTITION BY cr.[ticketID_FK]
              ORDER BY cr.[requestDate] DESC, cr.[clarificationRequestID] DESC
          ) AS [rn]
    FROM [Tickets].[ClarificationRequest] cr
    WHERE ISNULL(cr.[clarificationActive], 1) = 1
      AND cr.[clarificationStatus] = N'OPEN'
      AND cr.[ticketID_FK] IN ({idList})
) q
WHERE q.[rn] = 1;";

            var table = await ExecuteTicketFallbackQueryAsync(sql);
            var result = new Dictionary<long, long>();

            foreach (DataRow row in table.Rows)
            {
                if (!long.TryParse(row["ticketID_FK"]?.ToString(), out var ticketId))
                    continue;

                if (!long.TryParse(row["clarificationRequestID"]?.ToString(), out var clarificationRequestId))
                    continue;

                result[ticketId] = clarificationRequestId;
            }

            return result;
        }

        private async Task<DataTable> LoadClarificationRequestsFallbackAsync(int ticketId)
        {
            const string sql = @"
SELECT
      cr.[clarificationRequestID]
    , cr.[ticketID_FK]
    , cr.[requestedByUserID]
    , cr.[requestedFromUserID]
    , cr.[requestedFromDSDID_FK]
    , COALESCE(NULLIF(reason.[clarificationReasonName_A], N''), reason.[clarificationReasonName_E]) AS [clarificationReasonName_A]
    , cr.[requestNotes]
    , cr.[responseNotes]
    , cr.[requestDate]
    , cr.[responseDate]
    , cr.[clarificationStatus]
    , requestedByUser.[fullName] AS [requestedByName]
    , requestedFromUser.[fullName] AS [requestedFromUserName]
    , routeDsd.[DepartmentName] AS [requestedFromDepartmentName]
    , routeDsd.[DivisonName] AS [requestedFromDivisionName]
    , routeDsd.[SectionName] AS [requestedFromSectionName]
FROM [Tickets].[ClarificationRequest] cr
LEFT JOIN [Tickets].[ClarificationReason] reason
    ON cr.[clarificationReasonID_FK] = reason.[clarificationReasonID]
LEFT JOIN dbo.[V_GetFullStructureForDSD] routeDsd
    ON routeDsd.[DSDID] = cr.[requestedFromDSDID_FK]
OUTER APPLY (
    SELECT TOP 1 LTRIM(RTRIM(
          ISNULL(CASE WHEN ud.[firstName_A] IS NULL OR ud.[firstName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[firstName_E] ELSE ud.[firstName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[secondName_A] IS NULL OR ud.[secondName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[secondName_E] ELSE ud.[secondName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[thirdName_A] IS NULL OR ud.[thirdName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[thirdName_E] ELSE ud.[thirdName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[lastName_A] IS NULL OR ud.[lastName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[lastName_E] ELSE ud.[lastName_A] END, N'')
    )) AS [fullName]
    FROM [dbo].[UsersDetails] ud
    WHERE ud.[usersID_FK] = cr.[requestedByUserID]
    ORDER BY ud.[entryDate] DESC, ud.[usersDetailsID] DESC
) requestedByUser
OUTER APPLY (
    SELECT TOP 1 LTRIM(RTRIM(
          ISNULL(CASE WHEN ud.[firstName_A] IS NULL OR ud.[firstName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[firstName_E] ELSE ud.[firstName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[secondName_A] IS NULL OR ud.[secondName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[secondName_E] ELSE ud.[secondName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[thirdName_A] IS NULL OR ud.[thirdName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[thirdName_E] ELSE ud.[thirdName_A] END, N'') + N' ' +
          ISNULL(CASE WHEN ud.[lastName_A] IS NULL OR ud.[lastName_A] NOT LIKE N'%[ء-ي]%' THEN ud.[lastName_E] ELSE ud.[lastName_A] END, N'')
    )) AS [fullName]
    FROM [dbo].[UsersDetails] ud
    WHERE ud.[usersID_FK] = cr.[requestedFromUserID]
    ORDER BY ud.[entryDate] DESC, ud.[usersDetailsID] DESC
) requestedFromUser
WHERE cr.[ticketID_FK] = @ticketID
  AND ISNULL(cr.[clarificationActive], 1) = 1
ORDER BY cr.[requestDate] DESC, cr.[clarificationRequestID] DESC;";

            return await ExecuteTicketDetailsQueryAsync(sql, ("@ticketID", ticketId));
        }
    }
}