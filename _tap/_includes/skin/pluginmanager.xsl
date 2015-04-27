<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tap="xml.tapogee.com" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="xml" indent="no" omit-xml-declaration="yes" />
	
	<xsl:variable name="lcase" select="'abcdefghijklmnopqrstuvwxyz'" />
	<xsl:variable name="ucase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
	<xsl:variable name="tap" select="'xml.tapogee.com'" />
	
	<xsl:template match="/">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*[translate(local-name(),$ucase,$lcase)='form' 
	and translate(@*[translate(local-name(),$ucase,$lcase)='features' and translate(namespace-uri(),$ucase,$lcase)=$tap],$ucase,$lcase)!='false' 
	and normalize-space(@*[translate(local-name(),$ucase,$lcase)='errors' and translate(namespace-uri(),$ucase,$lcase)=$tap])='']">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:attribute name="tap:errors">pluginmanager_error</xsl:attribute>
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="pluginlist">
		<table class="plugin_index" cellspacing="0">
			<thead>
				<tr>
					<th class="plugin_index" colspan="2">
						The following components are available.
					</th>
				</tr>
			</thead>
			<tbody>
				<xsl:if test="not(./plugin)">
					<tr><td class="plugin_index" colspan="2">No components found.</td></tr>
				</xsl:if>
				<xsl:for-each select="plugin">
					<xsl:sort select="@name" />
					<tr>
						<td class="plugin_index">
							<div class="pluginmanager_pluginname">
								<tap:text><xsl:value-of select="@name" /></tap:text>
								<tap:text><xsl:value-of select="@edition" /></tap:text>
								<tap:text><xsl:value-of select="@version" /></tap:text>
								<tap:text><xsl:value-of select="@revision" /></tap:text>
							</div>
							
							<div class="pluginmanager_pluginprovider">
								<tap:text>released</tap:text>
								<tap:text type="date"><xsl:value-of select="@releasedate" /></tap:text>
								
								by 
								<xsl:choose>
									<xsl:when test="string-length(@profiderurl)!=0">
										<a class="pluginprovider" target="_blank" href="{@providerurl}">
											<tap:text><xsl:value-of select="@providername" /></tap:text>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<span class="pluginprovider">
											<tap:text><xsl:value-of select="@providername" /></tap:text>
										</span>
									</xsl:otherwise>
								</xsl:choose>
							</div>
							
							<div class="pluginmanager_plugindescription">
								<tap:text><xsl:value-of select="@description" /></tap:text>
							</div>
						</td>
						<td class="plugin_index">
							<form action="get.cfm" method="get" tap:features="false">
								<input type="hidden" name="serviceuri" value="{@serviceuri}" />
								<input type="hidden" name="pluginid" value="{@pluginid}" />
								<button type="submit">%tap_btn_install</button>
							</form>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
</xsl:stylesheet>
