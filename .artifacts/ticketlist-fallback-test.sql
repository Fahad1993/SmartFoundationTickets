SELECT TOP (5)
      t.[ticketID]
    , t.[ticketNo]
    , COALESCE(t.[title_A], t.[title]) AS [title]
    , CASE
        WHEN s.[serviceName_A] IS NULL OR s.[serviceName_A] NOT LIKE N'%[?-?]%'
          THEN s.[serviceName_E]
        ELSE s.[serviceName_A]
      END AS [serviceName_A]
    , s.[serviceName_E]
    , CASE
        WHEN rt.[requesterTypeName_A] IS NULL OR rt.[requesterTypeName_A] NOT LIKE N'%[?-?]%'
          THEN rt.[requesterTypeName_E]
        ELSE rt.[requesterTypeName_A]
      END AS [requesterTypeName_A]
    , rt.[requesterTypeName_E]
    , LTRIM(RTRIM(
          ISNULL(rud.firstName_A, N'') + N' ' +
          ISNULL(rud.secondName_A, N'') + N' ' +
          ISNULL(rud.thirdName_A, N'') + N' ' +
          ISNULL(rud.lastName_A, N'')
      )) AS [requesterName]
    , CASE
        WHEN p.[priorityName_A] IS NULL OR p.[priorityName_A] NOT LIKE N'%[?-?]%'
          THEN p.[priorityName_E]
        ELSE p.[priorityName_A]
      END AS [priorityName_A]
    , p.[priorityName_E]
    , CASE
        WHEN ts.[ticketStatusName_A] IS NULL OR ts.[ticketStatusName_A] NOT LIKE N'%[?-?]%'
          THEN ts.[ticketStatusName_E]
        ELSE ts.[ticketStatusName_A]
      END AS [ticketStatusName_A]
    , ts.[ticketStatusName_E]
    , ts.[ticketStatusCode]
    , LTRIM(RTRIM(
          ISNULL(aud.firstName_A, N'') + N' ' +
          ISNULL(aud.secondName_A, N'') + N' ' +
          ISNULL(aud.thirdName_A, N'') + N' ' +
          ISNULL(aud.lastName_A, N'')
      )) AS [assignedUserName]
    , sla.[elapsedMinutes]
    , t.[currentDSDID_FK]
    , t.[assignedUserID_FK]
    , t.[entryDate]
FROM [Tickets].[Ticket] t
LEFT JOIN [Tickets].[Service] s ON t.[serviceID_FK] = s.[serviceID]
LEFT JOIN [Tickets].[Priority] p ON t.[effectivePriorityID_FK] = p.[priorityID]
LEFT JOIN [Tickets].[TicketStatus] ts ON t.[ticketStatusID_FK] = ts.[ticketStatusID]
LEFT JOIN [Tickets].[RequesterType] rt ON t.[requesterTypeID_FK] = rt.[requesterTypeID]
OUTER APPLY (
    SELECT TOP 1
          CASE WHEN ud.firstName_A IS NULL OR ud.firstName_A NOT LIKE N'%[?-?]%' THEN ud.firstName_E ELSE ud.firstName_A END AS firstName_A
        , CASE WHEN ud.secondName_A IS NULL OR ud.secondName_A NOT LIKE N'%[?-?]%' THEN ud.secondName_E ELSE ud.secondName_A END AS secondName_A
        , CASE WHEN ud.thirdName_A IS NULL OR ud.thirdName_A NOT LIKE N'%[?-?]%' THEN ud.thirdName_E ELSE ud.thirdName_A END AS thirdName_A
        , CASE WHEN ud.lastName_A IS NULL OR ud.lastName_A NOT LIKE N'%[?-?]%' THEN ud.lastName_E ELSE ud.lastName_A END AS lastName_A
    FROM dbo.UsersDetails ud
    WHERE ud.usersID_FK = t.[requesterUserID_FK]
    ORDER BY ud.entryDate DESC, ud.usersDetailsID DESC
) rud
OUTER APPLY (
    SELECT TOP 1
          CASE WHEN ud.firstName_A IS NULL OR ud.firstName_A NOT LIKE N'%[?-?]%' THEN ud.firstName_E ELSE ud.firstName_A END AS firstName_A
        , CASE WHEN ud.secondName_A IS NULL OR ud.secondName_A NOT LIKE N'%[?-?]%' THEN ud.secondName_E ELSE ud.secondName_A END AS secondName_A
        , CASE WHEN ud.thirdName_A IS NULL OR ud.thirdName_A NOT LIKE N'%[?-?]%' THEN ud.thirdName_E ELSE ud.thirdName_A END AS thirdName_A
        , CASE WHEN ud.lastName_A IS NULL OR ud.lastName_A NOT LIKE N'%[?-?]%' THEN ud.lastName_E ELSE ud.lastName_A END AS lastName_A
    FROM dbo.UsersDetails ud
    WHERE ud.usersID_FK = t.[assignedUserID_FK]
    ORDER BY ud.entryDate DESC, ud.usersDetailsID DESC
) aud
OUTER APPLY (
    SELECT TOP 1 sl.[elapsedMinutes]
    FROM [Tickets].[TicketSLA] sl
    WHERE sl.[ticketID_FK] = t.[ticketID]
      AND sl.[slaTypeCode] = N'RESOLUTION'
      AND sl.[ticketSLAActive] = 1
) sla
WHERE t.[ticketActive] = 1
  AND (4 IS NULL OR t.[idaraID_FK] = 4)
ORDER BY t.[ticketID] DESC;
