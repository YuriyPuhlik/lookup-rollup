import { api } from 'lwc';
import BaseComponent from 'c/baseComponent';
import getFieldRollups from '@salesforce/apex/LWCFieldRollupController.getFieldRollups';
import saveFieldRollup from '@salesforce/apex/LWCFieldRollupController.saveFieldRollup';
import removeFieldRollup from '@salesforce/apex/LWCFieldRollupController.removeFieldRollup';
import LOCALE from '@salesforce/i18n/locale';
import CURRENCY from '@salesforce/i18n/currency';
import { formatString } from 'c/constants';
import { FIELD_ROLLUPS as labels } from 'c/labels';

const ROLLUPS_TO_SHOW = 5;

export default class FieldRollups extends BaseComponent {
    @api recordId;
    @api objectApiName;

    rollupsToShow = [];
    fieldRollups = [];
    isAddRollup = false;
    loading = false;
    labels = {
        title: labels.TITLE,
        showMore: labels.SHOW_MORE,
        showLess: labels.SHOW_LESS,
        saveSuccessMessage: labels.SAVE_SUCCESS_MESSAGE,
    };

    get isShowMore() {
        return this.showMoreNumber > 0;
    }

    get isShowLess() {
        return this.rollupsToShow.length > ROLLUPS_TO_SHOW;
    }

    get isShowFooter() {
        return !this.isAddRollup && (this.isShowMore || this.isShowLess);
    }

    get showMoreNumber() {
        return this.fieldRollups.length - this.rollupsToShow.length;
    }

    get showMoreLabel() {
        return formatString(this.labels.showMore, this.showMoreNumber);
    }

    showMore() {
        this.rollupsToShow = [...this.fieldRollups];
    }

    showLess() {
        this.rollupsToShow = [...this.fieldRollups].splice(0, ROLLUPS_TO_SHOW);
    }

    addRollup() {
        this.isAddRollup = true;
    }

    closeRollupAdd() {
        this.isAddRollup = false;
        this.showLess();
    }

    refresh() {
        this.getRollups();
    }

    removeRollup($event) {
        this.loading = true;
        const fieldRollupId = $event.currentTarget.getAttribute('data-key');
        removeFieldRollup({fieldRollupId})
            .then(() => {
                const index = this.fieldRollups.findIndex(rollup => rollup.id === fieldRollupId);
                this.fieldRollups.splice(index, 1);
                this.showLess();
            })
            .catch(error => {
                console.error(error)
            })
            .finally (() => {
                this.loading = false;
            });
    }

    saveRollup($event) {
        this.loading = true;
        const fieldRollup = $event.detail;
        fieldRollup.parentId = this.recordId;
        fieldRollup.parentObjectName = this.objectApiName;
        saveFieldRollup({request: JSON.stringify(fieldRollup)})
            .then(result => {
                this.fieldRollups.unshift(this.mapRollup(result));
                this.closeRollupAdd();
                this.showLess();
                this.showToastSuccess(this.labels.saveSuccessMessage);
            })
            .catch(error => {
                this.showToastError(error.body?.message);
                console.error(error)
            })
            .finally (() => {
                this.loading = false;
            });
    }

    getRollups() {
        this.loading = true;
        getFieldRollups({parentId: this.recordId})
            .then(result => {
                this.fieldRollups = result.map(fieldRollup => this.mapRollup(fieldRollup));
                this.showLess();
            })
            .catch(error => {
                console.error(error);
            })
            .finally (() => {
                this.loading = false;
            });
    }

    mapRollup(fieldRollup) {
        if (!fieldRollup.value && fieldRollup.value !== 0) {
            fieldRollup.formattedValue = '-';
        } else if (fieldRollup.isCurrency) {
            fieldRollup.formattedValue = new Intl.NumberFormat(LOCALE, {
                style: 'currency',
                currency: CURRENCY,
                currencyDisplay: 'symbol',
            }).format(fieldRollup.value)
        }
        return fieldRollup;
    }

    connectedCallback() {
        this.getRollups();
    }
}