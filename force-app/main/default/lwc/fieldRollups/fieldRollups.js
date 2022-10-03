import { LightningElement, api } from 'lwc';
import getFieldRollups from '@salesforce/apex/LWCFieldRollupController.getFieldRollups';
import LOCALE from '@salesforce/i18n/locale';
import CURRENCY from '@salesforce/i18n/currency';
import { formatString } from 'c/constants';

const ROLLUPS_TO_SHOW = 5;

export default class FieldRollups extends LightningElement {
    @api recordId;
    rollupsToShow = [];
    fieldRollups = [];
    labels = {
        title: 'Rollup Metrics',
        showMore: 'Show more ({0})',
        showLess: 'Show less',
    };

    get isShowMore() {
        return this.showMoreNumber > 0;
    }

    get isShowLess() {
        return this.rollupsToShow.length > ROLLUPS_TO_SHOW;
    }

    get isShowFooter() {
        return this.isShowMore || this.isShowLess;
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
        this.rollupsToShow = [...this.fieldRollups].splice(0, ROLLUPS_TO_SHOW);;
    }

    init() {
        getFieldRollups({recordId: this.recordId})
            .then(result => {
                this.fieldRollups = result.map(fieldRollup => {
                    if (!fieldRollup.value) {
                        fieldRollup.formattedValue = '-';
                    } else if (fieldRollup.isCurrency) {
                        fieldRollup.formattedValue = new Intl.NumberFormat(LOCALE, {
                            style: 'currency',
                            currency: CURRENCY,
                            currencyDisplay: 'symbol',
                        }).format(fieldRollup.value)
                    }
                    return fieldRollup;
                });
                this.showLess();
                console.log({fieldRollups: JSON.parse(JSON.stringify(this.fieldRollups))})
            })
            .catch(error => {
                console.error(error)
            });
    }

    connectedCallback() {
        this.init();
    }
}