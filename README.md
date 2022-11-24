# Field Rollups

The project contains a flexible lwc component called **Field Rollups**, which can be placed at any record page to calculate rollup values based on any child relationship type, be it lookup or master-detail. Here is an example of its usage on Account record page:

https://www.loom.com/share/ca4d261d95074e8ca5efb627324eadfd

## Steps to configure the component at the Salesforce org:
1. Pull changes from the **develop** branch
2. Push source code to the Salesforce org
3. Assign **Field Rollups Manager** permission set to your user or to those who will configure the component.
4. Go the record page editor, find the component **Field Rollups** among custom ones and drag & drop it to the necessary page area.
