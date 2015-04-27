<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tap="xml.tapogee.com" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" indent="no" omit-xml-declaration="yes" />
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="//tap:form[@class='rulecriteria']">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<input type="hidden" name="criteriatype" />
			<input type="hidden" name="ruleid" />
			<input type="hidden" name="criteria" />
			<select name="position" label="%tap_rulemanager_rulecriteria_position" />
			<button type="submit">%tap_rulemanager_rulecriteria_save</button>
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>