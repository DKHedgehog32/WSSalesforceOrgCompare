import { LightningElement } from 'lwc';
import LOGO from '@salesforce/resourceUrl/WSRlogo';

export default class WoonstadKioskNameChoice extends LightningElement {
    logoUrl = LOGO;
    showModal = false;
    altName = '';

    handleOwnName() {
        this.dispatchEvent(new CustomEvent('namechosen', { detail: null }));
    }

    showAltNameInput() {
        this.showModal = true;
    }

    handleAltNameChange(event) {
        this.altName = event.target.value;
    }

    closeModal() {
        this.showModal = false;
        this.altName = '';
    }

    submitAltName() {
        if (this.altName?.trim()) {
            this.dispatchEvent(new CustomEvent('namechosen', {
                detail: this.altName.trim()
            }));
            this.closeModal();
        } else {
            alert('Vul een alternatieve naam in.');
        }
    }
}