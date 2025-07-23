import { LightningElement, track } from 'lwc';
import LOGO from '@salesforce/resourceUrl/WSRlogo';

export default class WoonstadKlantWizardStart extends LightningElement {
    @track searchTerm = '';
    logoUrl = LOGO;

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    handleSearch() {
        console.log('Zoeken naar klant/bedrijf:', this.searchTerm);
    }

    handleCreateCompany() {
        console.log('Bedrijf aanmaken geselecteerd');
    }

    handleCreateCustomer() {
        console.log('Klant aanmaken geselecteerd');
    }

    handleCancel() {
        console.log('Annuleren');
    }

    handleNext() {
        console.log('Volgende stap');
    }
}