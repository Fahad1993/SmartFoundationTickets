CREATE PROCEDURE [Tickets].[ServiceDL]
(
      @pageName_  NVARCHAR(400)
    , @idaraID    INT
    , @entryData  INT
    , @hostName   NVARCHAR(400)
    , @filterServiceID  BIGINT = NULL
    , @filterTicketClassID INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @pageName_ = N'ServiceCatalogueList' OR @pageName_ IS NULL
    BEGIN
        SELECT
              v.[serviceID]
            , v.[serviceCode]
            , v.[serviceName_A]
            , v.[serviceName_E]
            , v.[serviceDesc]
            , v.[idaraID_FK]
            , v.[ticketClassID_FK]
            , v.[ticketClassName_A]
            , v.[ticketClassName_E]
            , v.[defaultPriorityID_FK]
            , v.[priorityName_A]
            , v.[priorityName_E]
            , v.[requiresLocation]
            , v.[allowsChildTickets]
            , v.[requiresQualityReview]
            , v.[serviceActive]
            , CASE WHEN v.[serviceActive] = 1 THEN N'نشطة' ELSE N'غير نشطة' END AS [serviceStatusText]
            , v.[departmentName]
            , v.[divisionSectionName]
            , v.[activeRoutingRuleID]
            , v.[activeTargetDSDID]
            , v.[routingDistributorID]
            , v.[routingEffectiveFrom]
            , v.[routingDepartmentName]
            , v.[routingDivisionName]
            , v.[routingSectionName]
            , v.[routingDistributorName]
            , v.[slaPolicyID]
            , v.[slaPriorityID_FK]
            , v.[slaPriorityName]
            , v.[firstResponseTargetMinutes]
            , v.[assignmentTargetMinutes]
            , v.[operationalCompletionTargetMinutes]
            , v.[finalClosureTargetMinutes]
        FROM [Tickets].[V_ServiceFullDefinition] v
        WHERE (v.[idaraID_FK] = @idaraID OR v.[idaraID_FK] IS NULL)
          AND (v.[serviceID] = @filterServiceID OR @filterServiceID IS NULL)
          AND (v.[ticketClassID_FK] = @filterTicketClassID OR @filterTicketClassID IS NULL)
        ORDER BY v.[serviceActive] DESC, v.[serviceID] DESC;

        SELECT [ticketClassID], [ticketClassName_A], [ticketClassName_E]
        FROM [Tickets].[TicketClass]
        WHERE [ticketClassActive] = 1
        ORDER BY [ticketClassID];

        SELECT [priorityID], [priorityName_A], [priorityName_E]
        FROM [Tickets].[Priority]
        WHERE [priorityActive] = 1
        ORDER BY [priorityID];

        RETURN;
    END

    IF @pageName_ = N'RoutingRuleLookup'
    BEGIN
        SELECT
              rr.[serviceRoutingRuleID]
            , rr.[serviceID_FK]
            , s.[serviceName_A]
            , s.[serviceName_E]
            , rr.[idaraID_FK]
            , rr.[targetDSDID_FK]
            , rr.[queueDistributorID_FK]
            , rr.[effectiveFrom]
            , rr.[effectiveTo]
            , rr.[changeReason]
            , rr.[serviceRoutingRuleActive]
        FROM [Tickets].[ServiceRoutingRule] rr
        INNER JOIN [Tickets].[Service] s ON rr.[serviceID_FK] = s.[serviceID]
        WHERE rr.[serviceRoutingRuleActive] = 1
          AND (rr.[idaraID_FK] = @idaraID OR rr.[idaraID_FK] IS NULL)
          AND rr.[effectiveFrom] <= GETDATE()
          AND (rr.[effectiveTo] IS NULL OR rr.[effectiveTo] > GETDATE())
        ORDER BY rr.[serviceRoutingRuleID] DESC;

        RETURN;
    END

    IF @pageName_ = N'SLAPolicyLookup'
    BEGIN
        SELECT
              sp.[serviceSLAPolicyID]
            , sp.[serviceID_FK]
            , s.[serviceName_A]
            , s.[serviceName_E]
            , sp.[priorityID_FK]
            , p.[priorityName_A]
            , sp.[firstResponseTargetMinutes]
            , sp.[assignmentTargetMinutes]
            , sp.[operationalCompletionTargetMinutes]
            , sp.[finalClosureTargetMinutes]
            , sp.[slaPolicyActive]
        FROM [Tickets].[ServiceSLAPolicy] sp
        INNER JOIN [Tickets].[Service] s ON sp.[serviceID_FK] = s.[serviceID]
        INNER JOIN [Tickets].[Priority] p ON sp.[priorityID_FK] = p.[priorityID]
        WHERE sp.[slaPolicyActive] = 1
          AND (sp.[idaraID_FK] = @idaraID OR sp.[idaraID_FK] IS NULL)
        ORDER BY sp.[serviceSLAPolicyID] DESC;

        RETURN;
    END

    IF @pageName_ = N'SuggestionReview'
    BEGIN
        SELECT
              scs.[serviceCatalogSuggestionID]
            , scs.[sourceTicketID_FK]
            , scs.[idaraID_FK]
            , scs.[proposedServiceName_A]
            , scs.[proposedServiceName_E]
            , COALESCE(scs.[proposedServiceDesc_A], scs.[proposedServiceDesc]) AS [proposedServiceDesc_A]
            , COALESCE(scs.[proposedServiceDesc_A], scs.[proposedServiceDesc]) AS [proposedServiceDesc]
            , scs.[proposedTargetDSDID_FK]
            , scs.[proposedPriorityID_FK]
            , scs.[approvalStatus]
            , scs.[approvedByUserID]
            , scs.[approvalDate]
            , scs.[createdServiceID_FK]
            , scs.[suggestionActive]
        FROM [Tickets].[ServiceCatalogSuggestion] scs
        WHERE (scs.[idaraID_FK] = @idaraID OR scs.[idaraID_FK] IS NULL)
          AND scs.[suggestionActive] = 1
        ORDER BY scs.[serviceCatalogSuggestionID] DESC;

        RETURN;
    END

    IF @pageName_ = N'ServiceDDL'
    BEGIN
        SELECT s.[serviceID], s.[serviceName_A], s.[serviceName_E]
        FROM [Tickets].[Service] s
        WHERE s.[serviceActive] = 1
          AND (s.[idaraID_FK] = @idaraID OR s.[idaraID_FK] IS NULL)
        ORDER BY s.[serviceName_A];

        RETURN;
    END
END
