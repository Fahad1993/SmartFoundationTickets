using Microsoft.AspNetCore.Mvc;
using SmartFoundation.UI.ViewModels.SmartPage;

namespace SmartFoundation.UI.ViewComponents.TicketTimeline
{
    public class TicketTimelineViewComponent : ViewComponent
    {
        public IViewComponentResult Invoke(TicketTimelineConfig model) => View("Default", model);
    }
}
