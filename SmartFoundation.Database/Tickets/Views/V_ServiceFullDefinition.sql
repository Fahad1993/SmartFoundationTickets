CREATE VIEW [Tickets].[V_ServiceFullDefinition]
AS
SELECT
      s.[serviceID]
    , s.[serviceCode]
    , s.[serviceName_A]
    , s.[serviceName_E]
    , s.[serviceDesc]
    , s.[idaraID_FK]
    , s.[ticketClassID_FK]
    , tc.[ticketClassCode]
    , tc.[ticketClassName_A] AS [ticketClassName_A]
    , tc.[ticketClassName_E] AS [ticketClassName_E]
    , s.[defaultPriorityID_FK]
    , p.[priorityCode]
    , p.[priorityName_A] AS [priorityName_A]
    , p.[priorityName_E] AS [priorityName_E]
    , s.[requiresLocation]
    , s.[allowsChildTickets]
    , s.[requiresQualityReview]
    , s.[serviceActive]
    , route.[serviceRoutingRuleID] AS [activeRoutingRuleID]
    , route.[targetDSDID_FK] AS [activeTargetDSDID]
    , route.[queueDistributorID_FK] AS [routingDistributorID]
    , route.[effectiveFrom] AS [routingEffectiveFrom]
    , routeDsd.[DepartmentName] AS [routingDepartmentName]
    , routeDsd.[DivisonName] AS [routingDivisionName]
    , routeDsd.[SectionName] AS [routingSectionName]
    , COALESCE(NULLIF(LTRIM(RTRIM(dist.[distributorName_A])), N''), dist.[distributorName_E]) AS [routingDistributorName]
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
    , sla.[serviceSLAPolicyID] AS [slaPolicyID]
    , sla.[priorityID_FK] AS [slaPriorityID_FK]
    , COALESCE(NULLIF(LTRIM(RTRIM(slaPriority.[priorityName_A])), N''), slaPriority.[priorityName_E]) AS [slaPriorityName]
    , sla.[firstResponseTargetMinutes]
    , sla.[assignmentTargetMinutes]
    , sla.[operationalCompletionTargetMinutes]
    , sla.[finalClosureTargetMinutes]
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
) route
LEFT JOIN dbo.[V_GetFullStructureForDSD] routeDsd
    ON routeDsd.[DSDID] = route.[targetDSDID_FK]
LEFT JOIN dbo.[Distributor] dist
    ON dist.[distributorID] = route.[queueDistributorID_FK]
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
) sla
LEFT JOIN [Tickets].[Priority] slaPriority
    ON slaPriority.[priorityID] = sla.[priorityID_FK];
