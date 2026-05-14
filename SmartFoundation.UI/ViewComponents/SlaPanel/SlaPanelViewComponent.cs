using Microsoft.AspNetCore.Mvc;
using SmartFoundation.UI.ViewModels.SmartPage;

namespace SmartFoundation.UI.ViewComponents.SlaPanel
{
    public class SlaPanelViewComponent : ViewComponent
    {
        public IViewComponentResult Invoke(SlaPanelConfig model) => View("Default", model);
    }
}
