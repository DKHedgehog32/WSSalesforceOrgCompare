import { LightningElement } from 'lwc';
import LOGO from '@salesforce/resourceUrl/WSRlogo';

export default class WoonstadKioskStartScreen extends LightningElement {
    logoUrl = LOGO;

    handleExistingClick() {
        this.dispatchEvent(new CustomEvent('existingselected'));
    }

    handleNewClick() {
        this.dispatchEvent(new CustomEvent('newvisitselected'));
    }
}