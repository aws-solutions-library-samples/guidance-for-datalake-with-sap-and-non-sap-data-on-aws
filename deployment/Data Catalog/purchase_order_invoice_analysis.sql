create view purchase_order_invoice_analysis AS
SELECT
	cds_po_item.purchaseorder as PurchaseOrderNumber,
	cds_po_item.purchaseorderitem as PurchaseOrderItem,
	cds_po_item.purchaseordercategory as PurchaseOrderCategory,
	cds_purchasing_document_category.purchasingdocumentcategoryname as PurchaseOrderCategoryDescription,
    cds_po_item.purchaseordertype as PurchaseOrderType,
	cds_purchase_order_type.purchasingdocumenttypename as PurchaseOrderTypeDescription,
	cds_po_header.purchaseordersubtype as PurchaseOrderSubtype,
	cds_purchase_order_subtype.purchasingdocumentsubtypename as PurchaseOrderSubtypeDescription,
	cds_po_item.purchasinggroup as PurchasingGroup,
	cds_purchasing_group.purchasinggroupname as PurchasingGroupDescription,
	cds_po_item.purchasingorganization as PurchasingOrganisation,
	cds_purchasing_organisation.purchasingorganizationname as PurchasingOrganisationDescription,
	cds_po_header.companycode as CompanyCode,
	cds_company_code.companycodename as CompanyCodeDescription,
	cds_po_item.plant as Plant,
	cds_plant.plantname as PlantDescription,
	cds_po_item.storagelocation as StorageLocation,
	cds_storage_location.storagelocationname as StorageLocationDescription,
	cds_po_header.purchasingdocumentorigin as PurchaseOrderOrigin,
	cds_purchasing_document_origin.purchasingdocumentoriginname as PurchaseOrderOriginName,
	cds_po_header.createdbyuser as CreatedBy,
	cds_po_header.creationdate as CreatedOn,
	cds_po_header.purchaseorderdate as PurchaseOrderDate,
	scheduleline.DeliveryDate,
	cds_po_item.supplier as Supplier,
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
	cds_po_item.netamount as NetAmount,
	invoices.InvoicedAmount,
	cds_po_header.documentcurrency as DocumentCurrency,
	cds_currency_text.currencyname as DocumentCurrencyDescription,
	cds_po_item.iscompletelydelivered as DeliveryCompleteIndicator,
	cds_po_item.isfinallyinvoiced as InvoiceCompleteIndicator,
	cds_po_item.material as Material,
	cds_material_text.productdescription as MaterialDescription,
	cds_po_item.materialgroup as MaterialGroup,
	cds_material_group.productgroupname as MaterialGroupDescription,
	cds_material_group.productgrouptext as MaterialGroupLongDescription,
	cds_po_item.purchaseorderitemtext as PurchaseOrderLineText,
	cds_po_item.invoicingparty as InvoicingParty,
	cds_po_item.orderquantity as OrderQuantity,
	scheduleline.GoodsReceiptQuantity,
	scheduleline.CommittedQuantity,
	invoices.InvoicedQuantity,
	cds_po_item.baseunit as BaseUnitofMeasure,
	cds_uom_text.unitofmeasurename as BaseUnitofMeasureDescription, 
	cds_uom_text.unitofmeasurelongname as BaseUnitofMeasureLongDescription
FROM
	afsaplakecurated.cds_po_header cds_po_header
INNER JOIN
	afsaplakecurated.cds_po_item cds_po_item on 
	cds_po_header.purchaseorder = cds_po_item.purchaseorder 
LEFT OUTER JOIN (
	SELECT 
		purchaseorder,
		purchaseorderitem,
		sum(cds_supplier_invoice.quantityinpurchaseorderunit) as InvoicedQuantity, 
		sum(cds_supplier_invoice.supplierinvoiceitemamount) as InvoicedAmount
	FROM  afsaplakecurated.cds_supplier_invoice as cds_supplier_invoice 
	GROUP BY 
		cds_supplier_invoice.purchaseorder,
		cds_supplier_invoice.purchaseorderitem 
	) invoices ON
	cds_po_item.purchaseorder = invoices.purchaseorder AND
	cds_po_item.purchaseorderitem = invoices.purchaseorderitem	
LEFT OUTER JOIN (
	SELECT 
		purchaseorder,
		purchaseorderitem,
		max(cds_po_schedule_line.schedulelinedeliverydate) as DeliveryDate,
		sum(cds_po_schedule_line.roughgoodsreceiptqty) as GoodsReceiptQuantity,
		sum(cds_po_schedule_line.schedulelinecommittedquantity) as CommittedQuantity
	FROM  afsaplakecurated.cds_po_schedule_line as cds_po_schedule_line 
	GROUP BY 
		cds_po_schedule_line.purchaseorder,
		cds_po_schedule_line.purchaseorderitem
	) scheduleline ON
	cds_po_item.purchaseorder = scheduleline.purchaseorder AND
	cds_po_item.purchaseorderitem = scheduleline.purchaseorderitem	
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
	cds_po_item.material = cds_material_text.product AND
	cds_material_text.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_payment_terms cds_payment_terms on
	cds_po_header.paymentterms = cds_payment_terms.paymentterms AND
	cds_payment_terms.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_plant cds_plant on
	cds_po_item.plant = cds_plant.plant
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
	cds_po_item.purchasinggroup = cds_purchasing_group.purchasinggroup
LEFT OUTER JOIN
	afsaplakecurated.cds_purchasing_organisation cds_purchasing_organisation on
	cds_po_item.purchasingorganization = cds_purchasing_organisation.purchasingorganization
LEFT OUTER JOIN
	afsaplakecurated.cds_supplier cds_supplier on
	cds_po_item.supplier = cds_supplier.supplier
LEFT OUTER JOIN
	afsaplakecurated.cds_uom_text cds_uom_text on
	cds_po_item.baseunit = cds_uom_text.unitofmeasure AND
	cds_uom_text.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_storage_location as cds_storage_location on 
	cds_po_item.plant = cds_storage_location.plant AND
	cds_po_item.storagelocation = cds_storage_location.storagelocation;