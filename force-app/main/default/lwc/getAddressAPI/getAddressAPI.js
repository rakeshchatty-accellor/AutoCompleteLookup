import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import LightningConfirm from 'lightning/confirm';
import searchAddress from '@salesforce/apex/GetAddressController.getAddresses';
import setAddress from '@salesforce/apex/GetAddressController.setAddresses';

//import { refreshApex } from '@salesforce/apex';

import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class GetAddressAPI extends LightningElement {
    @api recordId;
    searchValue = '';
    suggestions;
    selectedOptions;
    showdata = false;
    suggestionsData;
    isDisabled = true;
    value;

    //Dual Listbox
    get options() {
        return [
            { label: 'Billing Address', value: 'BillingAddress' },
            { label: 'Shipping Address', value: 'ShippingAddress' },
            { label: 'Person Mailing Address', value: 'PersonMailingAddress' },
            { label: 'Person Other Address', value: 'PersonOtherAddress' }
        ];
    }

    async handleRadioChange(event) {
        console.log('event', event)
        var selectedLabel = JSON.stringify(this.suggestionsData.find(opt => opt.value === event.detail.value).label);

        await LightningConfirm.open({
            message: 'Do you wish to apply changes.\n' + selectedLabel,
            label: 'Please Confirm',
            theme: 'warning',
        }).then((result) => {
            if (result) {
                setAddress({
                    recordId: this.recordId,
                    url: event.detail.value,
                    addressFields: this.selectedOptions
                }).then((result) => {
                    //refreshApex(this.result)
                    this.suggestionsData = null;
                    this.searchValue = null;

                    getRecordNotifyChange([{ recordId: this.recordId }]);
                    this.showNotification('Address updated successfully ', 'success')
                })
                .catch((error) => {
                        this.showNotification('error', 'error')
                        this.suggestionsData = null;
                        this.showdata = false;
                });
            } else {
                // uncheck checkbox
                console.log('this.suggestionsData', this.suggestionsData)
                this.suggestionsData = this.suggestionsData;
            }
        }).catch(error => {
            console.log('error',error)
            this.showNotification('error', 'error')
            this.suggestionsData = null;
        });
    }

    handleChange(event) {
        this.selectedOptions = event.detail.value
        this.selectedOptions == undefined ? this.isDisabled = true : this.isDisabled = false;
    }

    searchKeyword(event) {
            this.searchValue = event.target.value;
            console.log(this.searchValue);
            if(this.searchValue.length >= 3) {
            searchAddress({
                searchValue: this.searchValue
            })
            .then(result => {
                this.suggestions = JSON.parse(result).suggestions;
                this.suggestionsData = [];
                for (var key in this.suggestions) {
                    this.suggestionsData.push({ 'label': this.suggestions[key].address, 'value': this.suggestions[key].url });
                    this.showdata = true;
                }
            })
            .catch(error => {
                this.showNotification(error.body.message, 'error')
            });
        } else if (this.searchValue.length < 3 || this.searchValue == undefined) {
            this.suggestionsData = [];
            this.showdata = false;
        }
    }

    // setAddress(event) {
    //     console('FROM TABLE')
    //     setAddress({
    //         recordId: this.recordId,
    //         url: event.target.getAttribute("data-id")
    //     })
    //     .then(result => {
    //         // show toast and refresh UI.
    //         this.suggestions = null;
    //         this.searchValue = null;

    //         getRecordNotifyChange([{ recordId: this.recordId }]);
    //         this.showNotification('Address upadted sucessfully', 'success')
    //     })
    //     .catch(error => {
    //         this.suggestions = null;
    //         this.showNotification(error.body.message, 'error')
    //     });
    // }

    showNotification(message, variant) {
		const toastEvent = new ShowToastEvent({
			title: 'Get Address',
			message: message,
			variant: variant,
			mode: variant == 'error' ? 'sticky' : 'dismissible'
		});
		this.dispatchEvent(toastEvent);
	}
}