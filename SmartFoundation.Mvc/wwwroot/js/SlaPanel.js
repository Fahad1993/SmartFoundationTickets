(function () {
    function SlaPanel(config) {
        return {
            // Reactive properties from config
            ...config,

            // Component state
            expanded: false,

            // Methods
            init() {
                console.log('SlaPanel initialized', this);
            },

            toggleDetails() {
                this.expanded = !this.expanded;
            },

            // Format time in Arabic (similar to FormatElapsed in TicketDetails)
            formatTime(minutes) {
                if (minutes === null || minutes === undefined || isNaN(minutes)) return 'غير متوفر';

                const m = parseInt(minutes) || 0;
                const hours = Math.floor(m / 60);
                const mins = m % 60;

                if (hours === 0) return `${mins} د`;
                if (mins === 0) return `${hours} س`;
                return `${hours} س ${mins} د`;
            }
        };
    }

    // Register with Alpine.js
    if (window.Alpine) {
        window.Alpine.data('SlaPanel', SlaPanel);
    }

    // Register component when Alpine is ready
    document.addEventListener('alpine:init', () => {
        window.Alpine.data('SlaPanel', SlaPanel);
    });
})();
