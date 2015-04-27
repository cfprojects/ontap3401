<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet  [ 
	<!ENTITY apos   "&#39;">
	<!ENTITY nbsp   "&#160;">
	<!ENTITY copy   "&#169;">
	<!ENTITY reg    "&#174;">
	<!ENTITY trade  "&#8482;">
	<!ENTITY mdash  "&#8212;">
	<!ENTITY ldquo  "&#8220;">
	<!ENTITY rdquo  "&#8221;"> 
	<!ENTITY pound  "&#163;">
	<!ENTITY yen    "&#165;">
	<!ENTITY euro   "&#8364;">
]>
<xsl:stylesheet version="1.0" 
xmlns:fn="http://www.w3.org/2005/02/xpath-functions" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" indent="no" />
	
	<xsl:variable name="lcase" select="'abcdefghijklmnopqrstuvwxyz'" />
	<xsl:variable name="ucase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
	<xsl:variable name="nl" select="'&#10;'" />
	
	<xsl:template match="/mail">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="comment()" />
	
	<xsl:template match="text()">
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:variable name="e" select="translate(name(),$ucase,$lcase)" />
		<xsl:variable name="type" select="translate(normalize-space(@*[translate(name(),$ucase,$lcase)='type']),$ucase,$lcase)" />
		
		<xsl:choose>
			<xsl:when test="$e='button'" />
			
			<xsl:when test="$e='br'">
				<xsl:value-of select="$nl" />
			</xsl:when>
			
			<xsl:when test="$e='p'">
				<xsl:apply-templates />
				<xsl:value-of select="concat($nl,$nl)" />
			</xsl:when>
			
			<xsl:when test="$e='table'">
				<xsl:value-of select="$nl" />
				<xsl:apply-templates select=".//*[translate(name(),$ucase,$lcase)='tr']" />
			</xsl:when>
			
			<xsl:when test="$e='tr' or $e='div'">
				<xsl:variable name="row"><xsl:apply-templates /></xsl:variable>
				<xsl:if test="string-length(normalize-space($row)) > 0">
					<xsl:value-of select="concat(normalize-space($row),$nl)" />
				</xsl:if>
			</xsl:when>
			
			<xsl:when test="$e='input'">
				<xsl:choose>
					<xsl:when test="$type!='button' and $type!='password' and $type!='submit' and $type!='cancel' and $type!='image'">
						<xsl:value-of select="concat(normalize-space(@*[translate(name(),$ucase,$lcase)='value']),' ')" />
					</xsl:when>
					<xsl:otherwise><xsl:value-of select="' '" /></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			
			<xsl:when test="$e='select'">
				<xsl:variable name="selected" select="./*[translate(name(),$ucase,$lcase)='option' and @*[translate(name(),$ucase,$lcase)='selected']]" />
				<xsl:variable name="text">
					<xsl:choose>
						<xsl:when test="$selected">
							<xsl:apply-templates select="$selected" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="./*[translate(name(),$ucase,$lcase)='option'][1]" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="normalize-space($text)" />
			</xsl:when>
			
			<xsl:when test="$e='ol'">
				<xsl:call-template name="list">
					<xsl:with-param name="node" select="." />
					<xsl:with-param name="index" select="1" />
					<xsl:with-param name="item" select="1" />
				</xsl:call-template>
				<xsl:value-of select="$nl" />
			</xsl:when>
			
			<xsl:when test="$e='li'">
				<xsl:variable name="text"><xsl:apply-templates /></xsl:variable>
				<xsl:if test="string-length(normalize-space($text)) > 0">
					<xsl:value-of select="concat($nl,' - ',normalize-space($text))" />
				</xsl:if>
			</xsl:when>
			
			<xsl:when test="$e='blockquote'">
				<xsl:variable name="text"><xsl:apply-templates /></xsl:variable>
				<xsl:if test="string-length(normalize-space($text)) > 0">
					<xsl:value-of select="$nl" />
					<xsl:call-template name="blockquote">
						<xsl:with-param name="text" select="translate($text,'&#13;','&#10;')" />
					</xsl:call-template>
					<xsl:value-of select="$nl" />
				</xsl:if>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="list">
		<xsl:param name="node" />
		<xsl:param name="index" />
		<xsl:param name="item" />
		<xsl:variable name="child" select="./*[translate(name(),$ucase,$lcase)='li'][$index]" />
		<xsl:variable name="text"><xsl:apply-templates select="$child/node()" /></xsl:variable>
		
		<xsl:if test="$child">
			<xsl:choose>
				<xsl:when test="string-length(normalize-space($text)) > 0">
					<xsl:value-of select="concat($nl,' ',$item,'. ',normalize-space($text))" />
					<xsl:call-template name="list">
						<xsl:with-param name="node" select="$node" />
						<xsl:with-param name="index" select="1+$index" />
						<xsl:with-param name="item" select="1+$item" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="list">
						<xsl:with-param name="node" select="$node" />
						<xsl:with-param name="index" select="1+$index" />
						<xsl:with-param name="item" select="$item" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="blockquote">
		<xsl:param name="text" />
		
		<xsl:choose>
			<xsl:when test="contains($text,'&#10;')">
				<xsl:variable name="line" select="normalize-space(substring-before($text,'&#10;'))" />
				<xsl:variable name="next" select="substring-after($text,'&#10;')" />
				
				<xsl:call-template name="block-line">
					<xsl:with-param name="line" select="$line" />
				</xsl:call-template>
				<xsl:call-template name="blockquote">
					<xsl:with-param name="text" select="$next" />
				</xsl:call-template>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:call-template name="block-line">
					<xsl:with-param name="line" select="concat(normalize-space($text),$nl)" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="block-line">
		<xsl:param name="line" />
		
		<xsl:value-of select="concat($nl,'     ')" />
		
		<xsl:variable name="text">
			<xsl:call-template name="get-line">
				<xsl:with-param name="text" select="$line" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="shown" select="string-length($text)" />
		<xsl:variable name="available" select="string-length($line)" />
		<xsl:variable name="two" select="substring($line,$shown,2)" />
		
		<xsl:value-of select="$text" />
		<xsl:if test="$available > $shown">
			<xsl:variable name="start">
				<xsl:choose>
					<xsl:when test="substring($text,$shown,1)='-'">
						<xsl:choose>
							<xsl:when test="$two='--' or $two='- '">
								<xsl:value-of select="2+$shown" />
							</xsl:when>
							<xsl:when test="substring($two,1,1)='-'">
								<xsl:value-of select="1+$shown" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$shown" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="2+number($shown)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:call-template name="block-line">
				<xsl:with-param name="line" select="substring($line,$start,$available)" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="get-line">
		<xsl:param name="text" />
		<xsl:param name="line" />
		
		<xsl:variable name="max" select="50" />
		<xsl:variable name="wrap" select="45" />
		
		<xsl:variable name="available" select="string-length($text)" />
		<xsl:variable name="shown" select="string-length($line)" />
		<xsl:variable name="get" select="number($max)-$shown" />
		
		<xsl:choose>
			<xsl:when test="$get >= $available">
				<xsl:value-of select="$text" />
			</xsl:when>
			
			<xsl:when test="not(contains(substring($text,1,$get),' '))">
				<xsl:choose>
					<xsl:when test="contains(substring($text,1,$get),'-')">
						<xsl:value-of select="concat($line,' ',substring-before($text,'-'),'-')" />
					</xsl:when>
					
					<xsl:when test="$shown > $wrap">
						<xsl:value-of select="$line" />
					</xsl:when>
					
					<xsl:otherwise>
						<xsl:value-of select="concat($line,' ',substring($text,1,number($get)-1),'-')" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:variable name="temp">
				 <xsl:if test="$shown > 0"><xsl:value-of select="concat($line,' ')" /></xsl:if>
				 <xsl:value-of select="substring-before($text,' ')" />
				</xsl:variable>
				
				<xsl:call-template name="get-line">
					<xsl:with-param name="text" select="substring-after($text,' ')" />
					<xsl:with-param name="line" select="$temp" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>