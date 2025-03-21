let
    Source = Table.Combine({PrivatePrepped, NHSHospitals}),
    #"Filtered Rows" = Table.SelectRows(Source, each ([MD Action] = "Site has been revalidated and Qualification has been updated")),
    #"Removed Duplicates" = Table.Distinct(#"Filtered Rows", {"SiteNumber", "OperatingUnit"}),
    #"Merged Queries" = Table.NestedJoin(#"Removed Duplicates", {"Customer Category"}, Entitlement, {"Category"}, "Entitlement", JoinKind.LeftOuter),
    #"Added Custom" = Table.AddColumn(#"Merged Queries", "DateFrom", each DateTime.ToText(DateTime.LocalNow(), "dd-MMM-yyyy")),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Custom",{{"DateFrom", type text}}),
    #"Added Conditional Column" = Table.AddColumn(#"Changed Type", "DateTo", each if [Customer Category] = "HOSPITAL PRIVATE" then DateTime.ToText(Date.AddYears(DateTime.LocalNow(), 1), "dd-MMM-yyyy") else if [Customer Category] = "HOSPITAL NHS" then DateTime.ToText(Date.AddYears(DateTime.LocalNow(), 1), "dd-MMM-yyyy") else null),
    #"Uppercased Text" = Table.TransformColumns(#"Added Conditional Column",{{"DateFrom", Text.Upper, type text}, {"DateTo", Text.Upper, type text}}),
    #"Reordered Columns" = Table.ReorderColumns(#"Uppercased Text",{"OperatingUnit", "AccountNumber", "SiteNumber", "DateFrom", "DateTo", "Customer Category", "Customer Name", "Site Status", "Site Use Status", "ETR Hold", "Business Purpose", "Location Name", "Amgen Site Number", "Moderna Account Number", "Moderna Site Number", "Address 1", "Address 2", "Address 3", "Address 4", "City", "State", "Country", "Post code", "Entitlement Name", "Qual Type", "Qual Ref", "Valid From", "Valid To", "Last Order date", "MD Action", "MD Comments", "MD Initials", "MD Date", "Entitlement"}),
    #"Expanded {0}" = Table.ExpandTableColumn(#"Reordered Columns", "Entitlement", {"CD Schedule 2", "CD Schedule 3", "CD Schedule 4 part 1", "CD Schedule 4 part 2", "CD Schedule 5", "General Sales List", "Homeopathic", "Traditional Herbal Medicine", "Prescription Only Medicines [HUMAN]", "Chilled Products", "Immunoglobulin and products from blood", "Immunological Medicinal Products", "NHS Hospital", "Private Hospital"}, {"CD Schedule 2", "CD Schedule 3", "CD Schedule 4 part 1", "CD Schedule 4 part 2", "CD Schedule 5", "General Sales List", "Homeopathic", "Traditional Herbal Medicine", "Prescription Only Medicines [HUMAN]", "Chilled Products", "Immunoglobulin and products from blood", "Immunological Medicinal Products", "NHS Hospital", "Private Hospital"}),
    #"Unpivoted Columns" = Table.UnpivotOtherColumns(#"Expanded {0}", {"OperatingUnit", "AccountNumber", "SiteNumber", "DateFrom", "DateTo", "Customer Category", "Customer Name", "Site Status", "Site Use Status", "ETR Hold", "Business Purpose", "Location Name", "Amgen Site Number", "Moderna Account Number", "Moderna Site Number", "Address 1", "Address 2", "Address 3", "Address 4", "City", "State", "Country", "Post code", "Entitlement Name", "Qual Type", "Qual Ref", "Valid From", "Valid To", "Last Order date", "MD Action", "MD Comments", "MD Initials", "MD Date"}, "Attribute", "Value"),
    #"Reordered Columns1" = Table.ReorderColumns(#"Unpivoted Columns",{"OperatingUnit", "AccountNumber", "SiteNumber", "Attribute", "Value", "DateFrom", "DateTo", "Customer Category", "Customer Name", "Site Status", "Site Use Status", "ETR Hold", "Business Purpose", "Location Name", "Amgen Site Number", "Moderna Account Number", "Moderna Site Number", "Address 1", "Address 2", "Address 3", "Address 4", "City", "State", "Country", "Post code", "Entitlement Name", "Qual Type", "Qual Ref", "Valid From", "Valid To", "Last Order date", "MD Action", "MD Comments", "MD Initials", "MD Date"}),
    #"Renamed Columns" = Table.RenameColumns(#"Reordered Columns1",{{"Attribute", "Qualification"}}),
    #"Filtered Rows1" = Table.SelectRows(#"Renamed Columns", each ([Value] = "Y")),
    #"Reordered Columns2" = Table.ReorderColumns(#"Filtered Rows1",{"OperatingUnit", "AccountNumber", "SiteNumber", "Qualification", "Qual Ref", "DateFrom", "Value", "DateTo", "Customer Category", "Customer Name", "Site Status", "Site Use Status", "ETR Hold", "Business Purpose", "Location Name", "Amgen Site Number", "Moderna Account Number", "Moderna Site Number", "Address 1", "Address 2", "Address 3", "Address 4", "City", "State", "Country", "Post code", "Entitlement Name", "Qual Type", "Valid From", "Valid To", "Last Order date", "MD Action", "MD Comments", "MD Initials", "MD Date"}),
    #"Removed Other Columns" = Table.SelectColumns(#"Reordered Columns2",{"OperatingUnit", "AccountNumber", "SiteNumber", "Qualification", "Qual Ref", "DateFrom", "DateTo"})
in
    #"Removed Other Columns"
