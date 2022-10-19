@isTest
private class LWCFieldRollupControllerTest {
    
    @TestSetup
    static void makeData(){
        Account account = new Account(Name = 'Test Account');
        insert account;
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            contacts.add(new Contact(
                LastName = 'Test Contact ' + i,
                AccountId = account.Id
            ));
        }
        insert contacts;

        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 3; i++) {
            opportunities.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                AccountId = account.Id,
                Amount = 100 - i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addMonths(i),
                Probability = 90 - i
            ));
        }
        insert opportunities;

        List<Event> events = new List<Event>();
        for (Integer i = 0; i < opportunities.size(); i++) {
            events.add(new Event(
                WhoId = contacts[0].Id,
                WhatId = opportunities[i].Id,
                StartDateTime = DateTime.newInstance(2022, 10, 10, 10, 0, 0),
                EndDateTime = DateTime.newInstance(2022, 10, 10, 11 + i, 0, 0),
                Subject = 'Test Event',
                Description = 'Test Event'
            ));
        }
        insert events;
    }

    @isTest
    private static void testCountRollup() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :account.Id];
        FieldRollup__c fieldRollup = new FieldRollup__c(
            Name = 'Number of Contacts',
            ParentObjectName__c = 'Account',
            ChildObjectName__c = 'Contact',
            ChildRelationshipName__c = 'Contacts',
            RollupType__c = Constants.ROLLUP_TYPE_COUNT
        );
        insert fieldRollup;

        List<FieldRollup> calculatedRollups = LWCFieldRollupController.getFieldRollups(account.Id);
        System.assertEquals(1, calculatedRollups.size());
        System.assertEquals(fieldRollup.Id, calculatedRollups[0].id);
        System.assertEquals(fieldRollup.Name, calculatedRollups[0].label);
        System.assertEquals(contacts.size(), calculatedRollups[0].value);
        System.assertEquals(String.valueOf(contacts.size()), calculatedRollups[0].formattedValue);
        System.assertEquals(false, calculatedRollups[0].isCurrency);
    }

    @isTest
    private static void testSumCurrencyRollup() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<AggregateResult> aggregates = [SELECT AccountId, SUM(Amount) totalAmount FROM Opportunity WHERE AccountId = :account.Id GROUP BY AccountId];
        FieldRollup__c fieldRollup = new FieldRollup__c(
            Name = 'Total Amount',
            ParentObjectName__c = 'Account',
            ChildObjectName__c = 'Opportunity',
            ChildRelationshipName__c = 'Opportunities',
            RollupFieldName__c = 'Amount',
            RollupType__c = Constants.ROLLUP_TYPE_SUM
        );
        insert fieldRollup;

        List<FieldRollup> calculatedRollups = LWCFieldRollupController.getFieldRollups(account.Id);
        System.assertEquals(1, calculatedRollups.size());
        System.assertEquals(fieldRollup.Id, calculatedRollups[0].id);
        System.assertEquals(fieldRollup.Name, calculatedRollups[0].label);
        System.assertEquals(aggregates[0].get('totalAmount'), calculatedRollups[0].value);
        System.assertEquals(null, calculatedRollups[0].formattedValue);
        System.assertEquals(true, calculatedRollups[0].isCurrency);
    }

    @isTest
    private static void testMaxPercentRollup() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<AggregateResult> aggregates = [SELECT AccountId, MAX(Probability) maxProbability FROM Opportunity WHERE AccountId = :account.Id GROUP BY AccountId];
        FieldRollup__c fieldRollup = new FieldRollup__c(
            Name = 'Max Probability',
            ParentObjectName__c = 'Account',
            ChildObjectName__c = 'Opportunity',
            ChildRelationshipName__c = 'Opportunities',
            RollupFieldName__c = 'Probability',
            RollupType__c = Constants.ROLLUP_TYPE_MAX
        );
        insert fieldRollup;

        List<FieldRollup> calculatedRollups = LWCFieldRollupController.getFieldRollups(account.Id);
        System.assertEquals(1, calculatedRollups.size());
        System.assertEquals(fieldRollup.Id, calculatedRollups[0].id);
        System.assertEquals(fieldRollup.Name, calculatedRollups[0].label);
        System.assertEquals(aggregates[0].get('maxProbability'), calculatedRollups[0].value);
        System.assertEquals(String.valueOf(aggregates[0].get('maxProbability')) + '%', calculatedRollups[0].formattedValue);
        System.assertEquals(false, calculatedRollups[0].isCurrency);
    }

    @isTest
    private static void testMaxDateRollup() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<AggregateResult> aggregates = [SELECT AccountId, MAX(CloseDate) latestCloseDate FROM Opportunity WHERE AccountId = :account.Id GROUP BY AccountId];
        FieldRollup__c fieldRollup = new FieldRollup__c(
            Name = 'Latest Close Date',
            ParentObjectName__c = 'Account',
            ChildObjectName__c = 'Opportunity',
            ChildRelationshipName__c = 'Opportunities',
            RollupFieldName__c = 'CloseDate',
            RollupType__c = Constants.ROLLUP_TYPE_MAX
        );
        insert fieldRollup;

        List<FieldRollup> calculatedRollups = LWCFieldRollupController.getFieldRollups(account.Id);
        System.assertEquals(1, calculatedRollups.size());
        System.assertEquals(fieldRollup.Id, calculatedRollups[0].id);
        System.assertEquals(fieldRollup.Name, calculatedRollups[0].label);
        System.assertEquals(aggregates[0].get('latestCloseDate'), calculatedRollups[0].value);
        System.assertEquals(((Date) aggregates[0].get('latestCloseDate')).format(), calculatedRollups[0].formattedValue);
        System.assertEquals(false, calculatedRollups[0].isCurrency);
    }

    @isTest
    private static void testMinDateTimeRollup() {
        List<AggregateResult> aggregates = [SELECT WhoId, MIN(StartDateTime) earliestStartDate FROM Event GROUP BY WhoId];
        FieldRollup__c fieldRollup = new FieldRollup__c(
            Name = 'Earliest Start Date',
            ParentObjectName__c = 'Contact',
            ChildObjectName__c = 'Event',
            ChildRelationshipName__c = 'Events',
            RollupFieldName__c = 'StartDateTime',
            RollupType__c = Constants.ROLLUP_TYPE_MIN
        );
        insert fieldRollup;

        List<FieldRollup> calculatedRollups = LWCFieldRollupController.getFieldRollups(String.valueOf(aggregates[0].get('WhoId')));
        System.assertEquals(1, calculatedRollups.size());
        System.assertEquals(fieldRollup.Id, calculatedRollups[0].id);
        System.assertEquals(fieldRollup.Name, calculatedRollups[0].label);
        System.assertEquals(aggregates[0].get('earliestStartDate'), calculatedRollups[0].value);
        System.assertEquals(((DateTime) aggregates[0].get('earliestStartDate')).format(), calculatedRollups[0].formattedValue);
        System.assertEquals(false, calculatedRollups[0].isCurrency);
    }

    @isTest
    private static void testRollupCreationSuccess() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :account.Id];
        FieldRollup fieldRollup = new FieldRollup();
        fieldRollup.label = 'Number of Contacts';
        fieldRollup.parentObjectName = 'Account';
        fieldRollup.childObjectName = 'Contact';
        fieldRollup.childRelationshipName = 'Contacts';
        fieldRollup.rollupType = Constants.ROLLUP_TYPE_COUNT;
        fieldRollup.parentId = account.Id;

        FieldRollup calculatedRollup = LWCFieldRollupController.saveFieldRollup(JSON.serialize(fieldRollup));
        List<FieldRollup__c> createdRollups = [
            SELECT Id, Name, ParentObjectName__c, ChildObjectName__c, ChildRelationshipName__c,
            RollupType__c, RollupFieldName__c FROM FieldRollup__c
        ];
        System.assertEquals(1, createdRollups.size());
        System.assertEquals(fieldRollup.label, createdRollups[0].Name);
        System.assertEquals(fieldRollup.parentObjectName, createdRollups[0].ParentObjectName__c);
        System.assertEquals(fieldRollup.childObjectName, createdRollups[0].ChildObjectName__c);
        System.assertEquals(fieldRollup.childRelationshipName, createdRollups[0].ChildRelationshipName__c);
        System.assertEquals(fieldRollup.rollupType, createdRollups[0].RollupType__c);
        System.assertEquals(null, createdRollups[0].RollupFieldName__c);

        System.assertEquals(contacts.size(), calculatedRollup.value);
        System.assertEquals(String.valueOf(contacts.size()), calculatedRollup.formattedValue);
        System.assertEquals(false, calculatedRollup.isCurrency);
    }

    @isTest
    private static void testRollupCreationConfigurationError() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :account.Id];
        FieldRollup fieldRollup = new FieldRollup();
        fieldRollup.label = 'Number of Contacts';
        fieldRollup.parentObjectName = 'Account';
        fieldRollup.childObjectName = 'Invalid_Child';
        fieldRollup.childRelationshipName = 'Contacts';
        fieldRollup.rollupType = Constants.ROLLUP_TYPE_COUNT;
        fieldRollup.parentId = account.Id;

        try {
            LWCFieldRollupController.saveFieldRollup(JSON.serialize(fieldRollup));
            System.assert(false);
        } catch (Exception e) {
            System.assertEquals(FieldRollupSvc.INVALID_ROLLUP_CONFIGURATION_MESSAGE, e.getMessage());
        }
    }

    @isTest
    private static void testRollupCreationInvalidFieldTypeError() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        FieldRollup fieldRollup = new FieldRollup();
        fieldRollup.label = 'Latest Close Date';
        fieldRollup.parentObjectName = 'Account';
        fieldRollup.childObjectName = 'Opportunity';
        fieldRollup.childRelationshipName = 'Opportunities';
        fieldRollup.rollupFieldName = 'CloseDate';
        fieldRollup.rollupType = Constants.ROLLUP_TYPE_SUM;
        fieldRollup.parentId = account.Id;

        try {
            LWCFieldRollupController.saveFieldRollup(JSON.serialize(fieldRollup));
            System.assert(false);
        } catch (Exception e) {
            System.assertEquals(FieldRollupSvc.INVALID_ROLLUP_FIELD_TYPE_MESSAGE, e.getMessage());
        }
    }

    @isTest
    private static void testRollupDeletion() {
        FieldRollup__c fieldRollup = new FieldRollup__c(
            Name = 'Number of Contacts',
            ParentObjectName__c = 'Account',
            ChildObjectName__c = 'Contact',
            ChildRelationshipName__c = 'Contacts',
            RollupType__c = Constants.ROLLUP_TYPE_COUNT
        );
        insert fieldRollup;

        LWCFieldRollupController.removeFieldRollup(fieldRollup.Id);
        List<FieldRollup__c> currentRollups = [SELECT Id FROM FieldRollup__c];
        System.assertEquals(0, currentRollups.size());
    }
}
