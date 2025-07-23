import { LightningElement, track } from 'lwc';
import LOGO from '@salesforce/resourceUrl/WSRlogo';
import findCasesByAddressAndPerson from '@salesforce/apex/ExistingDossierService.findCasesByAddressAndPerson';

export default class WoonstadKioskExistingCase extends LightningElement {
    logoUrl = LOGO;

    @track street = '';
    @track houseNumber = '';
    @track postalCode = '';
    @track birthdate = '';

    @track addressOptions = [];
    @track selectedAddressId = '';
    @track cases = [];
    @track errorMessage = '';
    @track multipleAddresses = false;
    @track showCaseTable = false;

    searchAttempts = 0;
    maxSearchAttempts = 4;

    columns = [
        { label: 'Zaak Nr.', fieldName: 'caseNumber' },
        { label: 'Datum', fieldName: 'createdDate' },
        { label: 'Zaak Type', fieldName: 'subject' }
    ];

    get hasCases() {
        return this.cases && this.cases.length > 0;
    }

    handleStreetChange(e) {
        this.street = e.target.value;
    }

    handleHouseNumberChange(e) {
        this.houseNumber = e.target.value;
    }

    handlePostalCodeChange(e) {
        this.postalCode = e.target.value.replace(/\s/g, '').toUpperCase();
    }

    handleBirthdateChange(e) {
        this.birthdate = e.target.value;
    }

    handleAddressSearch() {
        this.errorMessage = '';
        this.showCaseTable = false;
        this.cases = [];

        if (!this.postalCode.match(/^\d{4}[A-Z]{2}$/)) {
            this.errorMessage = 'Voer een geldige postcode in (1234AB zonder spatie).';
            return;
        }

        if (!this.houseNumber || !this.birthdate) {
            this.errorMessage = 'Vul zowel huisnummer als geboortedatum in.';
            return;
        }

        this.searchAttempts++;

        findCasesByAddressAndPerson({
            postalCode: this.postalCode,
            houseNumber: this.houseNumber,
            birthdate: this.birthdate
        })
        .then(result => {
            if (result && result.length === 1) {
                this.selectedAddressId = result[0].addressId;
                this.cases = result;
                this.showCaseTable = true;
            } else if (result && result.length > 1) {
                this.addressOptions = result.map(a => ({
                    Id: a.addressId,
                    Name: a.addressName
                }));
                this.multipleAddresses = true;
            } else {
                this.errorMessage = 'Geen match gevonden.';
                if (this.searchAttempts >= this.maxSearchAttempts) {
                    this.dispatchEvent(new CustomEvent('maxaddresssearchretries', {
                        bubbles: true,
                        composed: true
                    }));
                }
            }
        })
        .catch(error => {
            this.errorMessage = 'Fout bij het zoeken van adressen of dossiers.';
            console.error(error);
        });
    }

    handleAddressSelect(e) {
        this.selectedAddressId = e.target.value;

        findCasesByAddressAndPerson({
            postalCode: this.postalCode,
            houseNumber: this.houseNumber,
            birthdate: this.birthdate,
            selectedAddressId: this.selectedAddressId
        })
        .then(result => {
            if (result && result.length > 0) {
                this.cases = result;
                this.showCaseTable = true;
                this.multipleAddresses = false;
            } else {
                this.errorMessage = 'Geen dossiers gevonden voor dit adres en geboortedatum.';
            }
        })
        .catch(error => {
            this.errorMessage = 'Fout bij het ophalen van dossiers.';
            console.error(error);
        });
    }
}