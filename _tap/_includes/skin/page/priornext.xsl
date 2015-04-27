<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />
	
	<xsl:param name="wrap" select="0" />
	<xsl:param name="previous" />
	<xsl:param name="next" />
	
	<xsl:variable name="lcase" select="'abcdefghijklmnopqrstuvwxyz'" />
	<xsl:variable name="ucase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
	<xsl:variable name="numpages" select="count(/pagelist/page)" />
	<xsl:variable name="page" select="/pagelist/@page" />
	<xsl:variable name="pagevariable" select="/pagelist/@variable" />
	
	<xsl:template name="crlf">
		<xsl:text disable-output-escaping="yes">&#13;&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="/pagelist">
		<xsl:variable name="wrap" select="translate(normalize-space($wrap),$ucase,$lcase)" />
		
		<div class="priornext" id="{@id}">
			<xsl:choose>
				<xsl:when test="$page &gt; 1">
					<xsl:call-template name="page">
						<xsl:with-param name="page" select="page[($page)-1]" />
						<xsl:with-param name="class" select="'previous'" />
						<xsl:with-param name="label" select="$previous" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$wrap=1 or $wrap='true' or $wrap='yes'">
					<xsl:call-template name="page">
						<xsl:with-param name="page" select="page[$numpages]" />
						<xsl:with-param name="class" select="'previous'" />
						<xsl:with-param name="label" select="$previous" />
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
			
			<xsl:value-of select="/pagelist/childdelimiter/text()" disable-output-escaping="yes" />
			
			<xsl:choose>
				<xsl:when test="$page &lt; $numpages">
					<xsl:call-template name="page">
						<xsl:with-param name="page" select="page[($page)+1]" />
						<xsl:with-param name="class" select="'next'" />
						<xsl:with-param name="label" select="$next" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$wrap=1 or $wrap='true' or $wrap='yes'">
					<xsl:call-template name="page">
						<xsl:with-param name="page" select="page[1]" />
						<xsl:with-param name="class" select="'next'" />
						<xsl:with-param name="label" select="$next" />
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<xsl:template name="page">
		<xsl:param name="page" />
		<xsl:param name="class" />
		<xsl:param name="label" />
		
		<xsl:variable name="pageid" select="/pagelist/@id" />
		
		<xsl:value-of select="/pagelist/prechild/text()" disable-output-escaping="yes" />
		<a class="{$class}" href="{$page/@href}&amp;{$pagevariable}={$page/@index}">
			<xsl:for-each select="/pagelist/events/*">
				<xsl:attribute name="on{name()}">document.getElementById('<xsl:value-of select="$pageid" />').href = this.href; return <xsl:value-of select="$pageid" />_<xsl:value-of select="name()" />(event);</xsl:attribute>
			</xsl:for-each>
			
			<xsl:value-of select="/pagelist/open/text()" disable-output-escaping="yes" />
			<xsl:value-of select="$label" />
			<xsl:value-of select="/pagelist/close/text()" disable-output-escaping="yes" />
		</a>
		<xsl:value-of select="/pagelist/postchild/text()" disable-output-escaping="yes" />
	</xsl:template>
</xsl:stylesheet>