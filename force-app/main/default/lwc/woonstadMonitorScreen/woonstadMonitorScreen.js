import { LightningElement, track } from 'lwc';
import getAcceptedVisitors from '@salesforce/apex/WoonstadMonitorController.getAcceptedVisitors';
//import soundFile from '@salesforce/resourceUrl/woonstad_alert'; // Static Resource//

export default class WoonstadMonitorScreen extends LightningElement {
    @track acceptedVisitors = [];
    lastNotifiedId = null;
    soundFileUrl = soundFile;

    // Lifecycle hook: fetch visitors every 5s
    connectedCallback() {
        this.fetchInterval = setInterval(() => {
            this.loadAccepted();
        }, 5000);
    }

    disconnectedCallback() {
        clearInterval(this.fetchInterval);
    }

    // Fetch accepted cases from Apex
    loadAccepted() {
        getAcceptedVisitors()
            .then(data => {
                this.acceptedVisitors = data.map(row => ({
                    caseId: row.Id,
                    name: row.SuppliedName,
                    desk: row.Owner.Name,
                    time: new Date(row.LastModifiedDate).toLocaleTimeString()
                }));

                const latestId = this.acceptedVisitors[0]?.caseId;
                if (latestId && latestId !== this.lastNotifiedId) {
                    this.lastNotifiedId = latestId;
                    this.playSound();
                }
            })
            .catch(error => {
                console.error('Error loading accepted visitors', error);
            });
    }

    // Play audio from hidden <audio> tag
    playSound() {
        const audio = this.template.querySelector('audio');
        if (audio) {
            audio.play().catch(e => console.warn('Audio play blocked:', e));
        }
    }
}