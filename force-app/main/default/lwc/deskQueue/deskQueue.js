/**
 * Created by harm on 21/02/2025.
 */
import {LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";

import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import getQueue from "@salesforce/apex/DeskQueueController.getQueue";
import getAtDesk from "@salesforce/apex/DeskQueueController.getAtDesk";

export default class DeskQueue extends LightningElement {
    @api recordId;
    @api hideMenu = false;
    channelName = '/event/Service_Desk_Registration_Queue_Update__e';
    records = [];
    atDesk = [];q
    subscription = {};
    urlParams = {};

    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if (pageRef) {
            // Extracting URL parameters
            this.urlParams = pageRef.state;
        }
    }
    connectedCallback() {
        if(!this.recordId) {
            if(this.urlParams) {
                this.recordId = this.urlParams.c__locationId;
            }
        }
        if(this.urlParams) {
            this.hideMenu = (this.urlParams.c__hideMenu === 'true');
        }

        this.subscribePfe();
        this.registerErrorListener();
        this.reload();
    }
    renderedCallback() {
        this.renderUi();
    }

    renderUi() {
        if(this.hideMenu) {
            document.querySelector("div.slds-no-print.oneAppNavContainer").style.display = "none";
            document.getElementById("oneHeader").style.display = "none";
        }
    }

    subscribePfe() {
        // Callback invoked whenever a new event message is received
        let messageCallback = function (response) {
            console.log('Received Platform Event: ', JSON.stringify(response.data.payload),'Comparing',this.recordId);
            if(response.data.payload.Service_Desk_Location__c == this.recordId) {
                console.log('Matches my location: Loading');
                this.reload();
            } else {
                console.log('Not my location: Ignoring');
            }
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback.bind(this)).then((response) => {
            // Response contains the subscription information on subscribe call
            console.log(
                'Subscription request sent to: ', JSON.stringify(response.channel)
            );
            this.subscription = response;
        });
    }
    unsubscribePfe() {

        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
        });
    }
    reload() {
        if(this.recordId) {
            getQueue({locationId: this.recordId})
                .then((result) => {
                    this.records = result;
                })
                .catch((error) => {
                    console.log(error);
                });
            getAtDesk({locationId: this.recordId})
                .then((result) => {
                    this.atDesk = result;
                })
                .catch((error) => {
                    console.log(error);
                });
        } else {
            console.log('No record id!');
        }
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError((error) => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }
    disconnectedCallback() {
        this.unsubscribePfe();
    }


}