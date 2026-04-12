CREATE PROCEDURE [Tickets].[ServiceDL]
(
      @pageName_  NVARCHAR(400)
    , @idaraID    INT
    , @entryData  INT
    , @hostName   NVARCHAR(400)
    , @filterServiceID  BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @pageName_ = N'ServiceCatalogueList' OR @pageName_ IS NULL
    BEGIN
        SELECT
              s.[serviceID]
            , s.[serviceCode]
            , s.[serviceName_A]
            , s.[serviceName_E]
            , s.[serviceDesc]
            , s.[idaraID_FK]
            , s.[ticketClassID_FK]
            , tc.[ticketClassName_A]
            , tc.[ticketClassName_E]
            , s.[defaultPriorityID_FK]
            , p.[priorityName_A]
            , p.[priorityName_E]
            , s.[requiresLocation]
            , s.[allowsChildTickets]
            , s.[requiresQualityReview]
            , s.[serviceActive]
        FROM [Tickets].[Service] s
        LEFT JOIN [Tickets].[TicketClass] tc ON s.[ticketClassID_FK] = tc.[ticketClassID]
        LEFT JOIN [Tickets].[Priority] p ON s.[defaultPriorityID_FK] = p.[priorityID]
        WHERE s.[serviceActive] = 1
          AND (s.[idaraID_FK] = @idaraID OR s.[idaraID_FK] IS NULL)
          AND (s.[serviceID] = @filterServiceID OR @filterServiceID IS NULL)
        ORDER BY s.[serviceID] DESC;

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
            , scs.[proposedServiceDesc]
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
