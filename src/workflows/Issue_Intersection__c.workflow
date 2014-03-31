<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>II_Object_Name_Populate_Account</fullName>
        <field>Object__c</field>
        <formula>&quot;Account&quot;</formula>
        <name>II - Object Name Populate (Account)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Object_Name_Populate_Contact</fullName>
        <field>Object__c</field>
        <formula>&quot;Contact&quot;</formula>
        <name>II - Object Name Populate (Contact)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Object_Name_Populate_Department</fullName>
        <field>Object__c</field>
        <formula>&quot;Department&quot;</formula>
        <name>II - Object Name Populate (Department)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Object_Name_Populate_Outreach</fullName>
        <field>Object__c</field>
        <formula>&quot;Outreach&quot;</formula>
        <name>II - Object Name Populate (Outreach)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Object_Name_Populate_Project</fullName>
        <field>Record_Name__c</field>
        <formula>Project__r.Name</formula>
        <name>II - Object Name Populate (Project)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Object_Populate_Campaign</fullName>
        <field>Object__c</field>
        <formula>&quot;Campaign&quot;</formula>
        <name>II - Object Populate (Campaign)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Object_Populate_Product</fullName>
        <field>Object__c</field>
        <formula>&quot;Deliverable&quot;</formula>
        <name>II - Object Populate (Product)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Record_Id_Populate_Account</fullName>
        <field>Record_Id__c</field>
        <formula>CASESAFEID(Account__c)</formula>
        <name>II - Record Id Populate (Account)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Record_Id_Populate_Contact</fullName>
        <field>Record_Id__c</field>
        <formula>CASESAFEID(Contact__c)</formula>
        <name>II - Record Id Populate (Contact)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Record_Id_Populate_Department</fullName>
        <field>Record_Id__c</field>
        <formula>CASESAFEID( Department__c)</formula>
        <name>II - Record Id Populate (Department)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Record_Id_Populate_Project</fullName>
        <field>Record_Id__c</field>
        <formula>CASESAFEID (Project__c)</formula>
        <name>II - Record Id Populate (Project)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Record_Name_Populate_Account</fullName>
        <field>Record_Name__c</field>
        <formula>Account__r.Name</formula>
        <name>II - Record Name Populate (Account)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Record_Name_Populate_Campaign</fullName>
        <field>Record_Name__c</field>
        <formula>Campaign__r.Name</formula>
        <name>II - Record Name Populate (Campaign)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Record_Name_Populate_Contact</fullName>
        <field>Record_Name__c</field>
        <formula>Contact__r.FirstName &amp;&quot; &quot;&amp; Contact__r.LastName</formula>
        <name>II - Record Name Populate (Contact)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Record_Name_Populate_Department</fullName>
        <field>Record_Name__c</field>
        <formula>Department__r.Name</formula>
        <name>II - Record Name Populate (Department)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Record_Name_Populate_Outreach</fullName>
        <field>Record_Name__c</field>
        <formula>Outreach__r.Name</formula>
        <name>II - Record Name Populate (Outreach)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Record_Name_Populate_Product</fullName>
        <field>Record_Name__c</field>
        <formula>Deliverable__r.Name</formula>
        <name>II - Record Name Populate (Product)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>II_Record_Name_Populate_Project</fullName>
        <field>Object__c</field>
        <formula>&quot;Project&quot;</formula>
        <name>II - Record Name Populate (Project)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>II - Record Name Populate %28Account%29</fullName>
        <actions>
            <name>II_Object_Name_Populate_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>II_Record_Id_Populate_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>II_Record_Name_Populate_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the &quot;Record Name&quot; field with the Account Name if an Account is assocated with an issue.</description>
        <formula>Account__c &lt;&gt; &quot;&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>II - Record Name Populate %28Campaign%29</fullName>
        <actions>
            <name>II_Object_Populate_Campaign</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>II_Record_Name_Populate_Campaign</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the &quot;Record Name&quot; field with the Campaign Name if a Campaign is associated with an issue.</description>
        <formula>Campaign__c  &lt;&gt; &quot;&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>II - Record Name Populate %28Contact%29</fullName>
        <actions>
            <name>II_Object_Name_Populate_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>II_Record_Id_Populate_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>II_Record_Name_Populate_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the &quot;Record Name&quot; field with the Contact Name if a Contact is associated with an issue.</description>
        <formula>Contact__c &lt;&gt; &quot;&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>II - Record Name Populate %28Department%29</fullName>
        <actions>
            <name>II_Object_Name_Populate_Department</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>II_Record_Id_Populate_Department</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>II_Record_Name_Populate_Department</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the &quot;Record Name&quot; field with the DepartmentName if a Department is assocated with an issue.</description>
        <formula>Department__c &lt;&gt; &quot;&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>II - Record Name Populate %28Outreach%29</fullName>
        <actions>
            <name>II_Object_Name_Populate_Outreach</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>II_Record_Name_Populate_Outreach</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the &quot;Record Name&quot; field with the Outreach Name if a Outreach is assocated with an issue.</description>
        <formula>Outreach__c &lt;&gt; &quot;&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>II - Record Name Populate %28Product%29</fullName>
        <actions>
            <name>II_Object_Populate_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>II_Record_Name_Populate_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the &quot;Record Name&quot; field with the Product Name if a Product is assocated with an issue.</description>
        <formula>Deliverable__c &lt;&gt; &quot;&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>II - Record Name Populate %28Project%29</fullName>
        <actions>
            <name>II_Object_Name_Populate_Project</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>II_Record_Id_Populate_Project</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>II_Record_Name_Populate_Project</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the &quot;Record Name&quot; field with the Project Name if a Project is assocated with an issue.</description>
        <formula>Project__c &lt;&gt; &quot;&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
