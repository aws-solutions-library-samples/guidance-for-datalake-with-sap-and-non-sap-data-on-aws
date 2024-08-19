CREATE VIEW supplier_invoice_analysis as 
SELECT
	cds_supplier_invoice.supplierinvoice as SupplierInvoice,
	cds_supplier_invoice.supplierinvoiceitem as SupplierInvoiceItem,
	cds_supplier_invoice.fiscalyear as Fiscalyear,
	cds_supplier_invoice.qtyinpurchaseorderpriceunit as InvoiceQuantity,
	cds_supplier_invoice.purchaseorderpriceunit as PriceUnit,
	cds_uom_text.unitofmeasurename as PriceUnitDescription, 
	cds_uom_text.unitofmeasurelongname as PriceUnitLongDescription,
	cds_supplier_invoice.purchaseorderquantityunit as QuantityUnit,
	cds_supplier_invoice.purchaseorder as PurchaseOrderNumber,
	cds_supplier_invoice.purchaseorderitem as PurchaseOrderItem,
	cds_supplier_invoice.prmthbreferencedocument as ReferenceDocument,
	cds_supplier_invoice.prmthbreferencedocumentfsclyr as ReferenceDocumentFiscalYear,
	cds_supplier_invoice.prmthbreferencedocumentitem as ReferenceDocumentItem,
	cds_supplier_invoice.purchaseorderitemmaterial as Material,
	cds_material_text.productdescription as MaterialDescription,
	cds_supplier_invoice.quantityinpurchaseorderunit as InvoiceQUantityInPOUnit,
	cds_supplier_invoice.suplrinvcitmhasqualityvariance as ItemHasQualityVariance,
	cds_supplier_invoice.suplrinvcitemhasordprcqtyvarc as ItemHasOrderPriceQuantityVariance,
	cds_supplier_invoice.suplrinvcitemhasqtyvariance as ItemHasQuantityVariance,
	cds_supplier_invoice.suplrinvcitemhaspricevariance as ItemHasPriceVariance,
	cds_supplier_invoice.suplrinvcitemhasothervariance as ItemHasOtherVariance,
	cds_supplier_invoice.suplrinvcitemhasamountoutsdtol as ItemHasItemAmountVariance,
	cds_supplier_invoice.suplrinvcitemhasdatevariance as ItemHasDateVariance,
	cds_supplier_invoice.issubsequentdebitcredit as IsSubsequentDebitCredit,
	cds_supplier_invoice.plant as Plant,
	cds_plant.plantname as PlantDescription,
	cds_supplier_invoice.documentcurrency as DocumentCurrency,
	cds_currency_text.currencyname as DocumentCurrencyDescription,
	cds_supplier_invoice.supplierinvoiceitemamount as InvoiceAmpount,
	cds_supplier_invoice.suplrinvcautomreducedamount as AutomaticallyReducedAmpunt,
	cds_supplier_invoice.unplanneddeliverycost as UnplanedDeliveryCost,
	cds_supplier_invoice.documentheadertext as DocumentHeaderText,
	cds_supplier_invoice.documentdate as DocumentDate,
	cds_supplier_invoice.postingdate as PostingDate,
	cds_supplier_invoice.companycode as CompanyCode,
	cds_company_code.companycodename as CompanyCodeDescription,
	cds_supplier_invoice.supplierinvoiceorigin,
	cds_supplier_invoice.invoicingparty as InvoicingParty,
	cds_supplier.suppliername as InvoicingPartyrName,
	cds_supplier.supplierfullname as InvoicingPartyFullName,
	cds_supplier_invoice.unplanneddeliverycosttaxcode as UnplannedDeliveryCostTaxCode,
	cds_supplier_invoice.reversedocument as ReverseDocument,
	cds_supplier_invoice.reversedocumentfiscalyear as ReverseDocumentFiscalYear,
	cds_supplier_invoice.supplierinvoiceidbyinvcgparty asSupplierInvoiceIDByInvoicingParty,
	cds_supplier_invoice.isinvoice as IsInvoice,
	cds_supplier_invoice.supplierinvoicestatus as SupplierInvoiceStatus,
	cds_invoice_status.supplierinvoicestatusdesc as SupplierInvoiceStatusDescription
FROM
	afsaplakecurated.cds_supplier_invoice cds_supplier_invoice
LEFT OUTER JOIN
	afsaplakecurated.cds_plant cds_plant on
	cds_supplier_invoice.plant = cds_plant.plant AND
	cds_plant.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_currency_text cds_currency_text on
	cds_supplier_invoice.documentcurrency = cds_currency_text.currency AND
	cds_currency_text.language = 'E'
LEFT OUTER JOIN 
	afsaplakecurated.cds_company_code cds_company_code on 
	cds_supplier_invoice.companycode = cds_company_code.companycode
LEFT OUTER JOIN
	afsaplakecurated.cds_supplier cds_supplier on
	cds_supplier_invoice.invoicingparty = cds_supplier.supplier
LEFT OUTER JOIN
	afsaplakecurated.cds_invoice_status cds_invoice_status on
	cds_supplier_invoice.supplierinvoicestatus = cds_invoice_status.supplierinvoicestatus AND
	cds_invoice_status.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_material_text cds_material_text on 
	cds_supplier_invoice.purchaseorderitemmaterial = cds_material_text.product AND
	cds_material_text.language = 'E'
LEFT OUTER JOIN
	afsaplakecurated.cds_uom_text cds_uom_text on
	cds_supplier_invoice.purchaseorderpriceunit = cds_uom_text.unitofmeasure AND
	cds_uom_text.language = 'E';