(function () {
    function normalizeStatusCode(value) {
        return (value || '').toString().trim().toUpperCase();
    }

    function normalizeActionCode(value) {
        return (value || '').toString().trim().toUpperCase();
    }

    function TicketTimeline(config) {
        return {
            // Reactive properties from config
            ...config,

            // Component state
            expanded: false,

            // Methods
            init() {
                this.events = (this.events || []).map((event, index) => ({
                    ...event,
                    _timelineKey: event?._timelineKey
                        || `${event?.actionCode || 'event'}-${event?.actionDate || 'no-date'}-${index}`
                }));
            },

            toggleExpanded() {
                this.expanded = !this.expanded;
            },

            getEventStatusClass(evt) {
                switch (normalizeActionCode(evt?.actionCode)) {
                    case 'CREATED':
                        return 'created';
                    case 'STATUS_CHANGED':
                        return 'changed';
                    case 'ROUTED':
                        return 'routed';
                    case 'ASSIGNED':
                        return 'assigned';
                    case 'STARTED':
                    case 'START_WORK':
                        return 'started';
                    case 'RESOLVED':
                        return 'resolved';
                    case 'CLOSED':
                        return 'closed';
                    case 'REJECTED':
                        return 'rejected';
                    case 'PAUSED':
                        return 'paused';
                    case 'RESUMED':
                    case 'RESUME_TICKET':
                        return 'resumed';
                    case 'REOPENED':
                        return 'reopened';
                    case 'ARBITRATION':
                        return 'arbitration';
                    case 'CLARIFICATION_REQUESTED':
                    case 'CLARIFICATION_RESPONDED':
                    case 'CLARIFICATION':
                        return 'clarification';
                    default:
                        return 'default';
                }
            },

            getDotColorClass(evt) {
                switch (normalizeActionCode(evt?.actionCode)) {
                    case 'CREATED':
                    case 'STATUS_CHANGED':
                    case 'ROUTED':
                    case 'ASSIGNED':
                    case 'CLARIFICATION':
                        return 'blue';
                    case 'STARTED':
                    case 'RESOLVED':
                    case 'CLOSED':
                    case 'RESUMED':
                    case 'CLARIFICATION_RESPONDED':
                    case 'CHILD_CREATED':
                        return 'green';
                    case 'PAUSED':
                    case 'REOPENED':
                        return 'yellow';
                    case 'REJECTED':
                        return 'red';
                    case 'ARBITRATION':
                    case 'CLARIFICATION_REQUESTED':
                        return 'purple';
                    default:
                        return 'gray';
                }
            },

            getDotStateClass(evt, index, total) {
                void evt;
                if (this.isLast(index, total)) {
                    return 'active';
                }

                return 'completed';
            },

            getStatusBadgeClass(statusCode) {
                switch (normalizeStatusCode(statusCode)) {
                    case 'ROUTED':
                    case 'ASSIGNED':
                    case 'PAUSED':
                        return 'blue';
                    case 'IN_PROGRESS':
                    case 'REOPENED':
                        return 'yellow';
                    case 'RESOLVED':
                    case 'CLOSED':
                        return 'green';
                    case 'REJECTED':
                        return 'red';
                    case 'CLARIFICATION':
                    case 'ARBITRATION':
                        return 'purple';
                    case 'NEW':
                    default:
                        return 'gray';
                }
            },

            isLast(index, total) {
                return index === total - 1;
            },

            formatDate(value) {
                if (!value) {
                    return '';
                }

                // Handle string values from SQL database
                const date = new Date(value);
                if (Number.isNaN(date.getTime())) {
                    return value;
                }

                return new Intl.DateTimeFormat('ar-SA', {
                    day: '2-digit',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                }).format(date);
            }
        };
    }

    // Register with Alpine.js
    if (window.Alpine) {
        window.Alpine.data('TicketTimeline', TicketTimeline);
    }

    // Register component when Alpine is ready
    document.addEventListener('alpine:init', () => {
        window.Alpine.data('TicketTimeline', TicketTimeline);
    });
})();
