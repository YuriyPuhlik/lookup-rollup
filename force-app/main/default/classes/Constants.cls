public with sharing class Constants {

    public static final String ROLLUP_TYPE_COUNT = 'COUNT';
    public static final String ROLLUP_TYPE_SUM = 'SUM';
    public static final String ROLLUP_TYPE_MAX = 'MAX';
    public static final String ROLLUP_TYPE_MIN = 'MIN';
    
    public static final List<Schema.DisplayType> ROLLUP_SUM_FIELD_TYPES = new List<Schema.DisplayType>{
        Schema.DisplayType.Currency,
        Schema.DisplayType.Double,
        Schema.DisplayType.Integer,
        Schema.DisplayType.Long,
        Schema.DisplayType.Percent
    };
    
    public static final List<Schema.DisplayType> ROLLUP_MAX_MIN_FIELD_TYPES = new List<Schema.DisplayType>{
        Schema.DisplayType.Date,
        Schema.DisplayType.DateTime
    };

    public static List<Schema.DisplayType> MaxMinFieldTypes {
        get {
            if (MaxMinFieldTypes == null) {
                MaxMinFieldTypes = new List<Schema.DisplayType>(ROLLUP_SUM_FIELD_TYPES);
                MaxMinFieldTypes.addAll(ROLLUP_MAX_MIN_FIELD_TYPES);
            }
            return MaxMinFieldTypes;
        }
        private set;
    }

    public static final Map<String, List<Schema.DisplayType>> ROLLUP_TYPE_TO_FIELD_TYPE_MAP = new Map<String, List<Schema.DisplayType>>{
        ROLLUP_TYPE_SUM => ROLLUP_SUM_FIELD_TYPES,
        ROLLUP_TYPE_MAX => MaxMinFieldTypes,
        ROLLUP_TYPE_MIN => MaxMinFieldTypes
    };
}
