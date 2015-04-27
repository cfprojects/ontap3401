<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tap="xml.tapogee.com" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" indent="no" omit-xml-declaration="yes" />
	
	<xsl:variable name="lcase" select="'abcdefghijklmnopqrstuvwxyz'" />
	<xsl:variable name="ucase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
	<xsl:variable name="tap" select="'xml.tapogee.com'" />
	
	<xsl:template match="comment()" />
	
	<xsl:template match="text()">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*[translate(name(),$ucase,$lcase)='menu']">
		<xsl:variable name="temp" select="@*[translate(name(),$ucase,$lcase)='label']" />

		<xsl:variable name="label">
			<xsl:choose>
				<xsl:when test="string-length($temp)!=0">
					<xsl:value-of select="$temp" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@*[translate(name(),$ucase,$lcase)='path']" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="path">
			<xsl:variable name="temp" select="@*[translate(name(),$ucase,$lcase)='path']" />
			<xsl:if test="string-length($temp)!=0">
				<xsl:variable name="parent">
					<xsl:value-of select="../@*[translate(name(),$ucase,$lcase)='path']" />
				</xsl:variable>
				<xsl:if test="string-length($parent)!=0">
					<xsl:value-of select="concat($parent,'/')" />
				</xsl:if>
				<xsl:value-of select="$temp" />
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="gp" select="translate(substring-before($path,'/'),$ucase,$lcase)" />
		
		<xsl:variable name="gatepath">
			<xsl:if test="$gp='cfc' or $gp='libraries' or $gp='customtags'">
				<xsl:value-of select="translate($path,'/.','__')" />
			</xsl:if>
		</xsl:variable>
		
		<xsl:if test="string-length($path)!=0">
			<tap:tree href="?netaction={$path}" 
			domain="docs" target="doc_frame_content" 
			label="{$label}" tap:variable="tree[&#39;{$path}&#39;]">
				<xsl:if test="string-length($gatepath)!=0">
					<xsl:attribute name="id">
						<xsl:value-of select="$gatepath" />
					</xsl:attribute>
					<tap:event name="treeopen">
						<tap:if condition="document.getElementById('{$gatepath}_loading') is not null">
							<tap:trigger element="docgate" event="gatesend" 
								clientarguments="'?netaction=nav&amp;nav={$gatepath}'"  />
						</tap:if>
					</tap:event>
					<tap:tree id="{$gatepath}_loading" label="Loading..." />
				</xsl:if>
				<xsl:apply-templates />
			</tap:tree>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>