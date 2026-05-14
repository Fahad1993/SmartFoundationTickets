namespace SmartFoundation.UI.ViewModels.SmartPage
{
    public class TicketTimelineConfig
    {
        public string? Title { get; set; } = "سجل المتابعة";
        public List<TimelineEvent>? Events { get; set; }
        public bool ShowEmptyState { get; set; } = true;
        public string EmptyStateText { get; set; } = "لا توجد سجلات متابعة متاحة لهذه التذكرة.";
    }

    public class TimelineEvent
    {
        public string? ActionCode { get; set; }
        public string? ActionNameAr { get; set; }
        public string? NewStatusCode { get; set; }
        public string? NewStatusName_A { get; set; }
        public string? Notes { get; set; }
        public string? PerformerName { get; set; }
        public DateTime? ActionDate { get; set; }
    }
}
