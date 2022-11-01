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

    public static final String CONDITION_EQUALS = 'Equals';
    public static final String CONDITION_DOES_NOT_EQUAL = 'Does Not Equal';
    public static final String CONDITION_GREATER_THAN = 'Greater Than';
    public static final String CONDITION_LESS_THAN = 'Less Than';
    public static final String CONDITION_GREATER_THAN_OR_EQUAL = 'Greater Than or Equal';
    public static final String CONDITION_LESS_THAN_OR_EQUAL = 'Less Than or Equal';
    public static final String CONDITION_IS_NULL = 'Is Null';

    public static final List<String> ALL_CONDITIONS = new List<String>{
        CONDITION_EQUALS, CONDITION_DOES_NOT_EQUAL, CONDITION_LESS_THAN,
        CONDITION_GREATER_THAN_OR_EQUAL, CONDITION_LESS_THAN_OR_EQUAL,
        CONDITION_IS_NULL
    };

    public static final List<String> STRING_CONDITIONS = new List<String>{
        CONDITION_EQUALS, CONDITION_DOES_NOT_EQUAL, CONDITION_IS_NULL
    };

    public static final List<String> BOOLEAN_CONDITIONS = new List<String>{
        CONDITION_EQUALS, CONDITION_DOES_NOT_EQUAL
    };

    public static final Map<Schema.DisplayType, List<String>> FIELD_TYPE_CONDITIONS_MAP = new Map<Schema.DisplayType, List<String>>{
        Schema.DisplayType.Boolean => BOOLEAN_CONDITIONS,
        Schema.DisplayType.Currency => ALL_CONDITIONS,
        Schema.DisplayType.Date => ALL_CONDITIONS,
        Schema.DisplayType.DateTime => ALL_CONDITIONS,
        Schema.DisplayType.Double => ALL_CONDITIONS,
        Schema.DisplayType.Email => STRING_CONDITIONS,
        Schema.DisplayType.ID => STRING_CONDITIONS,
        Schema.DisplayType.Integer => ALL_CONDITIONS,
        Schema.DisplayType.Long => ALL_CONDITIONS,
        Schema.DisplayType.MultiPicklist => STRING_CONDITIONS,
        Schema.DisplayType.Percent => ALL_CONDITIONS,
        Schema.DisplayType.Phone => STRING_CONDITIONS,
        Schema.DisplayType.Picklist => STRING_CONDITIONS,
        Schema.DisplayType.Reference => STRING_CONDITIONS,
        Schema.DisplayType.String => STRING_CONDITIONS,
        Schema.DisplayType.URL => STRING_CONDITIONS
    };
}
