CREATE VIEW purchase_order_analysis AS
SELECT
	cds_po_schedule_line.purchaseorder as PurchaseOrderNumber,
	cds_po_schedule_line.purchaseorderitem as PurchaseOrderItem,
	cds_po_schedule_line.purchaseorderscheduleline as PurchaseOrderScheduleLine,
	cds_po_item.purchaseordercategory as PurchaseOrderCategory,
	cds_purchasing_document_category.purchasingdocumentcategoryname as PurchaseOrderCategoryDescription,
    cds_po_item.purchaseordertype as PurchaseOrderType,
	cds_purchase_order_type.purchasingdocumenttypename as PurchaseOrderTypeDescription,
	cds_po_header.purchaseordersubtype as PurchaseOrderSubtype,
	cds_purchase_order_subtype.purchasingdocumentsubtypename as PurchaseOrderSubtypeDescription,
	cds_po_schedule_line.purchasinggroup as PurchasingGroup,
	cds_purchasing_group.purchasinggroupname as PurchasingGroupDescription,
	cds_po_schedule_line.purchasingorganization as PurchasingOrganisation,
	cds_purchasing_organisation.purchasingorganizationname as PurchasingOrganisationDescription,
	cds_po_header.companycode as CompanyCode,
	cds_company_code.companycodename as CompanyCodeDescription,
	cds_po_schedule_line.plant as Plant,
	cds_plant.plantname as PlantDescription,
	cds_po_schedule_line.storagelocation as StorageLocation,
	cds_storage_location.storagelocationname as StorageLocationDescription,
	cds_po_header.purchasingdocumentorigin as PurchaseOrderOrigin,
	cds_purchasing_document_origin.purchasingdocumentoriginname as PurchaseOrderOriginName,
	cds_po_header.createdbyuser as CreatedBy,
	cds_po_header.creationdate as CreatedOn,
	cds_po_header.purchaseorderdate as PurchaseOrderDate,
	cds_po_schedule_line.schedulelinedeliverydate as ScheduledDeliveryDate,
	cds_po_schedule_line.supplier as Supplier,
	cds_supplier.suppliername as SupplierName,
	cds_supplier.supplierfullname as SupplierFullName,
	cds_po_header.paymentterms as PaymentTerms,
	cds_payment_terms.paymenttermsdescription as PaymentTermsDescription,
	cds_payment_terms.paymenttermsname as PaymetnTermsName,
	cds_po_header.incotermsclassification as IncotermsClassification,
	cds_incoterms_classification.incotermsclassificationname as IncotermsClassificationDescription,
	cds_po_header.incotermsversion as IncotermsVersion,
	cds_incoterms_version.incotermsversionname as IncotermsVersionDescription,
	cds_po_item.netpriceamount as NetPrice,
	cds_po_header.documentcurrency as DocumentCurrency,
	cds_currency_text.currencyname as DocumentCurrencyDescription,
	cds_po_schedule_line.iscompletelydelivered as DeliveryCompleteIndicator,
	cds_po_schedule_line.isfinallyinvoiced as InvoiceCompleteIndicator,
	cds_po_schedule_line.material as Material,
	cds_material_text.productdescription as MaterialDescription,
	cds_po_schedule_line.materialgroup as MaterialGroup,
	cds_material_group.productgroupname as MaterialGroupDescription,
	cds_material_group.productgrouptext as MaterialGroupLongDescription,
	cds_po_schedule_line.purchaseorderitemtext as PurchaseOrderLineText,
	cds_po_schedule_line.invoicingparty as InvoicingParty,
	cds_po_schedule_line.schedulelineorderquantity as ScheduleLineQuantity,
	cds_po_schedule_line.roughgoodsreceiptqty as GoodsReceiptQuantity,
	cds_po_schedule_line.schedulelinecommittedquantity as CommittedQuantity,
	cds_po_item.baseunit as BaseUnitofMeasure,
	cds_uom_text.unitofmeasurename as BaseUnitofMeasureDescription, 
	cds_uom_text.unitofmeasurelongname as BaseUnitofMeasureLongDescription
FROM
	afsaplakecurated.cds_po_header cds_po_header
INNER JOIN
	afsaplakecurated.cds_po_item cds_po_item on 
	cds_po_header.purchaseorder = cds_po_item.purchaseorder 
INNER JOIN 
	afsaplakecurated.cds_po_schedule_line cds_po_schedule_line on 	
	cds_po_item.purchaseorder = cds_po_schedule_line.purchaseorder AND
	cds_po_item.purchaseorderitem = cds_po_schedule_line.purchaseorderitem
LEFT OUTER JOIN 
	afsaplakecurated.cds_company_code cds_company_code on 
	cds_po_header.companycode = cds_company_code.companycode
LEFT OUTER JOIN
	afsaplakecurated.cds_currency_text cds_currency_text on
	cds_po_header.documentcurrency = cds_currency_text.currency AND
	cds_currency_text.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_incoterms_classification cds_incoterms_classification on
	cds_po_header.incotermsclassification = cds_incoterms_classification.incotermsclassification AND
	cds_incoterms_classification.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_incoterms_version cds_incoterms_version on
	cds_po_header.incotermsversion = cds_incoterms_version.incotermsversion AND
	cds_incoterms_version.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_material_group cds_material_group on
	cds_po_item.materialgroup = cds_material_group.productgroup AND
	cds_material_group.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_material_text cds_material_text on 
	cds_po_schedule_line.material = cds_material_text.product AND
	cds_material_text.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_payment_terms cds_payment_terms on
	cds_po_header.paymentterms = cds_payment_terms.paymentterms AND
	cds_payment_terms.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_plant cds_plant on
	cds_po_schedule_line.plant = cds_plant.plant
LEFT OUTER JOIN
	afsaplakecurated.cds_purchase_order_subtype cds_purchase_order_subtype on 
	cds_po_header.purchaseordersubtype = cds_purchase_order_subtype.purchasingdocumentsubtype AND
	cds_purchase_order_subtype.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_purchase_order_type cds_purchase_order_type on
	cds_po_item.purchaseordertype = cds_purchase_order_type.purchasingdocumenttype AND
	cds_po_item.purchaseordercategory = cds_purchase_order_type.purchasingdocumentcategory AND
	cds_purchase_order_type.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_purchasing_document_category cds_purchasing_document_category on
	cds_po_item.purchaseordercategory = cds_purchasing_document_category.purchasingdocumentcategory AND 
	cds_purchasing_document_category.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_purchasing_document_origin cds_purchasing_document_origin on
	cds_po_header.purchasingdocumentorigin = cds_purchasing_document_origin.purchasingdocumentorigin AND
	cds_purchasing_document_origin.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_purchasing_group cds_purchasing_group on
	cds_po_schedule_line.purchasinggroup = cds_purchasing_group.purchasinggroup
LEFT OUTER JOIN
	afsaplakecurated.cds_purchasing_organisation cds_purchasing_organisation on
	cds_po_schedule_line.purchasingorganization = cds_purchasing_organisation.purchasingorganization
LEFT OUTER JOIN
	afsaplakecurated.cds_supplier cds_supplier on
	cds_po_schedule_line.supplier = cds_supplier.supplier
LEFT OUTER JOIN
	afsaplakecurated.cds_uom_text cds_uom_text on
	cds_po_schedule_line.baseunit = cds_uom_text.unitofmeasure AND
	cds_uom_text.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_storage_location as cds_storage_location on 
	cds_po_schedule_line.plant = cds_storage_location.plant AND
	cds_po_schedule_line.storagelocation = cds_storage_location.storagelocation;