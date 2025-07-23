import { LightningElement } from 'lwc';
import LOGO from '@salesforce/resourceUrl/WSRlogo';

export default class WoonstadKioskForm extends LightningElement {
    logoUrl = LOGO;

    firstName = '';
    lastName = '';
    contactInfo = '';
    visitReason = '';
    notes = '';

    showErrorModal = false;

    visitOptions = [
        { label: 'Huurbetaling', value: 'Huurbetaling' },
        { label: 'Reparatieverzoek', value: 'Reparatieverzoek' },
        { label: 'Overige vragen', value: 'Overige vragen' }
    ];

    handleChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
    }

    handleSubmit() {
        const hasAtLeastOne = [this.firstName, this.lastName, this.contactInfo]
            .some(v => v && v.trim() !== '');

        if (!hasAtLeastOne) {
            this.showErrorModal = true;
            return;
        }

        this.dispatchEvent(new CustomEvent('submitform', {
            detail: {
                firstName: this.firstName,
                lastName: this.lastName,
                contactInfo: this.contactInfo,
                visitReason: this.visitReason,
                notes: this.notes
            }
        }));
    }

    closeErrorModal() {
        this.showErrorModal = false;
    }
}