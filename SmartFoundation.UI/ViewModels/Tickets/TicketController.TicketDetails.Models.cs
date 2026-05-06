using SmartFoundation.UI.ViewModels.SmartForm;

namespace SmartFoundation.UI.ViewModels.SmartPage
{
    public class TicketDetailsData
    {
        public string? TicketId { get; set; }
        public string? TicketNo { get; set; }
        public string? Title { get; set; }
        public string? Description { get; set; }
        public string? StatusCode { get; set; }
        public string? StatusName { get; set; }
        public string? PriorityCode { get; set; }
        public string? PriorityName { get; set; }
        public bool IsBlocked { get; set; }
        public string? ServiceName { get; set; }
        public string? RequesterName { get; set; }
        public string? RequesterTypeName { get; set; }
        public string? AssignedUserName { get; set; }
        public string? TicketClassName { get; set; }
        public string? CurrentDsdId { get; set; }
        public string? EntryDate { get; set; }
        public string? LastUpdated { get; set; }
        public string? OperationalResolutionDate { get; set; }
        public string? FinalClosureDate { get; set; }
        public string? BackLinkUrl { get; set; } = "/Ticket/TicketList";
        public List<TicketRelatedItem> RelatedTickets { get; set; } = new();
        public List<TicketPauseItem> PauseSessions { get; set; } = new();
        public List<TicketQualityItem> QualityReviews { get; set; } = new();
        public List<TicketClarificationItem> ClarificationRequests { get; set; } = new();
        public List<TicketInfoItem> TicketInfo { get; set; } = new();
        public bool RequiresQualityReview { get; set; }
        public string? LocationBuildingNo { get; set; }
        public string? LocationUnitNo { get; set; }
        public string? LocationArea { get; set; }
        public int? SlaElapsedMinutes { get; set; }
        public int? SlaTargetMinutes { get; set; }
        public bool SlaIsBreached { get; set; }
    }

    public class TicketAction
    {
        public string Code { get; set; } = string.Empty;
        public string Label { get; set; } = string.Empty;
        public string Icon { get; set; } = string.Empty;
        public string Color { get; set; } = "secondary";
        public string Title { get; set; } = string.Empty;
        public FormConfig? Form { get; set; }
        public bool Show { get; set; } = true;
        public List<string> ShowForStatuses { get; set; } = new();
    }

    public class TicketRelatedItem
    {
        public string? TicketId { get; set; }
        public string? TicketNo { get; set; }
        public string? Title { get; set; }
        public string? StatusCode { get; set; }
        public string? StatusName { get; set; }
        public string? PriorityName { get; set; }
    }

    public class TicketPauseItem
    {
        public string? ReasonName { get; set; }
        public string? Notes { get; set; }
        public string? Start { get; set; }
        public string? End { get; set; }
        public bool IsActive { get; set; }
    }

    public class TicketQualityItem
    {
        public string? ResultName { get; set; }
        public string? ResultCode { get; set; }
        public string? Notes { get; set; }
        public string? ReviewerName { get; set; }
        public bool Finalized { get; set; }
        public string? ReviewDate { get; set; }
    }

    public class TicketClarificationItem
    {
        public string? RequestId { get; set; }
        public string? ReasonName { get; set; }
        public string? RequestNotes { get; set; }
        public string? RequestDate { get; set; }
        public string? Status { get; set; }
        public string? TargetDsdName { get; set; }
    }

    public class TicketInfoItem
    {
        public string Label { get; set; } = string.Empty;
        public string? Value { get; set; }
        public string? Icon { get; set; }
    }
}
