namespace SmartFoundation.UI.ViewModels.SmartPage
{
    public class SlaPanelConfig
    {
        public string? Title { get; set; } = "Service Level Agreement";
        public string? Icon { get; set; } = "fa-clock";
        public int ResponseTimeMinutes { get; set; } = 240;
        public int ResolutionTimeMinutes { get; set; } = 480;
        public decimal AchievedPercentage { get; set; } = 95.5m;
        public bool ShowDetails { get; set; } = true;
        public string? ColorScheme { get; set; } = "blue";
    }
}
