import { LightningElement, api, track } from 'lwc';
import fetchAddresses from '@salesforce/apex/KadasterAddressLookupController.fetchAddresses';

import postalCode from '@salesforce/label/c.Postal_Code';
import houseNumber from '@salesforce/label/c.House_Number';
import selectAnAddress from '@salesforce/label/c.Select_An_Address';
import noAddressFound from '@salesforce/label/c.No_Address_Found';
import postalCodeHelpText from '@salesforce/label/c.Postal_Code_Help_Text';
import houseNumberHelpText from '@salesforce/label/c.House_Number_Help_Text';

export default class KadasterLookupFlow extends LightningElement {
    @track postalCode = '';
    @track houseNumber = '';
    @track addressList = [];
    @track addressOptions = [];
    @track selectedAddressIndex = null;
    @track loading = false;
    @track error = null;
    @track postalCodeValid = true;

    debounceTimer;

    // Flow output variables
    @api streetName;
    @api houseNumber;
    @api houseLetter;
    @api houseNumberAddition;
    @api postalCode;
    @api city;
    @api addressableObjectIdentification;

    label = {
        postalCode,
        houseNumber,
        selectAnAddress,
        noAddressFound,
        postalCodeHelpText,
        houseNumberHelpText
    };

    handlePostalCodeChange(event) {
        const value = (event.detail.value || '').toString().trim().toUpperCase();
        this.postalCode = value;

        const pattern = /^[0-9]{4}[A-Z]{2}$/;
        this.postalCodeValid = pattern.test(value);

        this.clearOutputFields();
        if (this.postalCodeValid) {
            this.scheduleDebouncedFetch();
        }
    }

    handleHouseNumberChange(event) {
        const value = (event.detail.value || '').toString().trim();
        this.houseNumber = value;

        this.clearOutputFields();
        this.scheduleDebouncedFetch();
    }

    scheduleDebouncedFetch() {
        if (this.debounceTimer) {
            clearTimeout(this.debounceTimer);
        }

        const isReady = this.postalCode && this.houseNumber && this.postalCodeValid;
        if (isReady) {
            this.debounceTimer = setTimeout(() => {
                this.fetchAddressData();
            }, 1000);
        }
    }

    async fetchAddressData() {
        this.loading = true;
        this.error = null;
        this.addressOptions = [];
        this.selectedAddressIndex = null;

        try {
            const data = await fetchAddresses({
                postalCode: this.postalCode,
                houseNumber: this.houseNumber
            });

            this.addressList = data;

            if (data.length === 0) {
                this.error = this.label.noAddressFound;
            } else if (data.length === 1) {
                this.addressOptions = [{
                    label: data[0].addressLabel,
                    value: '0'
                }];
                this.selectedAddressIndex = '0';
                this.setOutputFields(data[0]);
            } else {
                this.addressOptions = data.map((address, index) => ({
                    label: address.addressLabel,
                    value: index.toString()
                }));
                this.selectedAddressIndex = null;
            }
        } catch (e) {
            this.error = 'Error retrieving address.';
        } finally {
            this.loading = false;
        }
    }

    handleAddressSelect(event) {
        const value = event.detail.value;
        if (!value) {
            this.selectedAddressIndex = null;
            return;
        }

        const index = parseInt(value, 10);
        this.selectedAddressIndex = value;
        this.setOutputFields(this.addressList[index]);
        this.error = null;
    }

    setOutputFields(address) {
        this.streetName = address.streetName;
        this.houseNumberOutput = address.houseNumber;
        this.houseLetter = address.houseLetter;
        this.houseNumberAddition = address.houseNumberAddition;
        this.postalCodeOutput = address.postalCode;
        this.city = address.city;
        this.addressableObjectIdentification = address.addressableObjectIdentification;
    }

    clearOutputFields() {
        this.selectedAddressIndex = null;
        this.streetName = null;
        this.houseLetter = null;
        this.houseNumberAddition = null;
        this.city = null;
        this.addressableObjectIdentification = null;
    }

    @api
    get isValid() {
        if (this.addressList.length > 1 && !this.selectedAddressIndex) {
            this.error = 'Please select an address before continuing.';
            return false;
        }
        this.error = null;
        return !!(this.streetName && this.addressableObjectIdentification);
    }

    get postalCodeInputClass() {
        return this.postalCodeValid ? '' : 'slds-has-error';
    }
}