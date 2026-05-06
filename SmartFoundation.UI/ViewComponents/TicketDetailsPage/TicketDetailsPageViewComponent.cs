using Microsoft.AspNetCore.Mvc;
using SmartFoundation.UI.ViewModels.SmartPage;

namespace SmartFoundation.UI.ViewComponents.TicketDetailsPage
{
    public class TicketDetailsPageViewComponent : ViewComponent
    {
        public IViewComponentResult Invoke(SmartPageViewModel model) => View("Default", model);
    }
}
