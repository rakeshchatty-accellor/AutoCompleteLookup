import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import LightningConfirm from 'lightning/confirm';
import getTypeOfAddress from '@salesforce/apex/GetAddressController.getTypeOfAddress';
import searchAddress from '@salesforce/apex/GetAddressController.getAddresses';
import setAddress from '@salesforce/apex/GetAddressController.setAddresses';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class GetAddressAutocomplete extends LightningElement {

    @api recordId;

    // Picklist
    showPicklist = false;
    size;
    selectedAddressTypes=[];
    options=[];

    //search input
    searchValue;
    suggestions;
    isFocussed = false;
    suggestionsData = [];
    url;

    // On Load get type of address picklist values
    connectedCallback() {
        getTypeOfAddress({
            recordId: this.recordId
        })
        .then(result => {
            var options = result;
            for (var key in result) {
                this.options.push({'label': key, 'value': result[key]});
            }
            if (this.options.length > 0) {
                this.size = this.options.length;
                this.showPicklist = true;
            }
        })
        .catch(error => {
            console.log(error)
        })
    }

    // search address suggestions
    searchData(event) {
        this.searchValue = event.detail.value;
        if (this.searchValue.length >= 3) {
            this.isFocussed = true;
            searchAddress({
                searchValue: this.searchValue
            })
            .then(result => {
                var suggestions = JSON.parse(result).suggestions;
                this.suggestionsData = [];
                for (var key in JSON.parse(result).suggestions) {
                    this.suggestionsData.push({ 'label': suggestions[key].address, 'value': suggestions[key].url });
                }
            })
            .catch(error => {
                this.showNotification(error.body.message, 'error')
            });
        } else if (this.searchValue.length < 3 || this.searchValue == undefined) {
            this.suggestionsData = [];
            this.url = null;
        }
    }
    
    get noOptions() {
        return this.suggestionsData.length === 0;
    }

    handleSelectOption(event) {
        this.searchValue = event.currentTarget.dataset.label;
        this.url = event.currentTarget.dataset.value;
        this.isFocussed = false;
    }

    handleSave() {        
        if(this.url != null && this.selectedAddressTypes != null) {
            setAddress({
                recordId: this.recordId,
                url: this.url,
                addressFields: this.selectedAddressTypes
            })
            .then(result => {
                this.suggestionsData = [];
                this.searchValue = null;
                getRecordNotifyChange([{ recordId: this.recordId }]);
                this.showNotification('Address upadted sucessfully', 'success')
            })
            .catch(error => {
                this.suggestionsData = [];
                this.showNotification(error.body.message, 'error')
            });
        }
    }
    //On change of Address type Multi-select picklist
    handleChange(event) {
        this.selectedAddressTypes = event.detail.value;
    }

    get dropdownClasses() {
        
        let dropdownClasses = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        
        // Show dropdown list on focus
        if (this.isFocussed && this.searchValue != null) {
            dropdownClasses += ' slds-is-open';
        }

        return dropdownClasses;
    }

    get isDisabled() {
        if (this.url != null && (this.selectedAddressTypes.length > 0 || !this.showPicklist)) {
            return false;
        } else {
            return true;
        }
    }

    handleFocus() {
        this.isFocussed = true;
    }

    handleBlur() {
        setTimeout(() => { this.isFocussed = false; }, 500);
    }

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