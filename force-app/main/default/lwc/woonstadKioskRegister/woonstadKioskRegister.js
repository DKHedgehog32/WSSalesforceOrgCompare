import { LightningElement } from 'lwc';

export default class WoonstadKioskRegister extends LightningElement {
    currentStep = 'start';
    visitorData = {};
    retryAttempts = 0;
    maxRetries = 3;

    // Step Visibility Getters
    get showStart() {
        return this.currentStep === 'start';
    }

    get showForm() {
        return this.currentStep === 'form';
    }

    get showExistingCase() {
        return this.currentStep === 'existingCase';
    }

    get showNameChoice() {
        return this.currentStep === 'nameChoice';
    }

    get showSuccess() {
        return this.currentStep === 'success';
    }

    // Start screen button handlers
    handleExisting() {
        this.retryAttempts = 0;
        this.currentStep = 'existingCase';
    }

    handleNewVisit() {
        this.currentStep = 'form';
    }

    // Form submission handler
    handleFormSubmit(event) {
        this.visitorData = { ...event.detail };
        this.currentStep = 'nameChoice';
    }

    // Name choice handler
    handleNameChoice(event) {
        const altName = event.detail.name;
        const finalName = altName || `${this.visitorData.firstName} ${this.visitorData.lastName}`;
        console.log('Bezoeker geregistreerd als:', finalName);

        // (Optional) Save visitor record logic here

        this.currentStep = 'success';

        // Return to start after 6 seconds
        setTimeout(() => {
            this.currentStep = 'start';
        }, 6000);
    }

    // Existing case match found
    handleValidCase(event) {
        const selectedCaseId = event.detail.caseId;
        console.log('Gevonden case ID:', selectedCaseId);

        // (Optional) Update state with selected case ID
        this.currentStep = 'success';

        setTimeout(() => {
            this.currentStep = 'start';
        }, 6000);
    }

    // Existing case - no match, allow retry or fallback to new visit
    handleNoMatch() {
        this.retryAttempts++;
        if (this.retryAttempts >= this.maxRetries) {
            this.currentStep = 'form';
        } else {
            // Optionally show message or reset the existing case screen
            this.currentStep = 'existingCase';
        }
    }

    // Optional: when retry limit is exceeded
    handleRetryLimit() {
        this.currentStep = 'form';
    }
}