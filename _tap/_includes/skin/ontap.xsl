<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tap="xml.tapogee.com" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" indent="no" omit-xml-declaration="yes" />
	
	<xsl:variable name="lcase" select="'abcdefghijklmnopqrstuvwxyz'" />
	<xsl:variable name="ucase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
	<xsl:variable name="buttons" select="',submit,reset,button,image,'" />
	<xsl:variable name="typelist" select="concat(',hidden',$buttons)" />
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
	
	<xsl:template match="*[translate(local-name(),'DIV','div')='div' and translate(namespace-uri(),$ucase,$lcase)=$tap]">
		<div>
			<xsl:copy-of select="@*" />
			<tap:gateway>
				<tap:event name="gaterespond">
					<tap:import target="javascript:element.parentNode" />
				</tap:event>
				
				<xsl:apply-templates />
			</tap:gateway>
		</div>
	</xsl:template>
	
	<xsl:template match="*[translate(name(),'NOBR','nobr')='nobr']">
		<span style="white-space:nowrap;">
			<xsl:apply-templates />
		</span>
	</xsl:template>
	
	<xsl:template match="*[translate(name(),$ucase,$lcase)='center']">
		<div style="text-align: center;">
			<xsl:apply-templates />
		</div>
	</xsl:template>
	
	<xsl:template match="@*[translate(name(),$ucase,$lcase)='valign']">
		<xsl:variable name="style" select="../@*[translate(name(),$ucase,$lcase)='style']" />
		<xsl:attribute name="style">
			<xsl:value-of select="concat('vertical-align: ',text(),'; ',$style)" />
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="@*[translate(name(),$ucase,$lcase)='align']">
		<xsl:variable name="style" select="../@*[translate(name(),$ucase,$lcase)='style']" />
		<xsl:attribute name="style">
			<xsl:value-of select="concat('text-align: ',text(),'; ',$style)" />
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="@*[translate(name(),$ucase,$lcase)='color']">
		<xsl:variable name="style" select="../@*[translate(name(),$ucase,$lcase)='style']" />
		<xsl:attribute name="style">
			<xsl:value-of select="concat('color: ',text(),'; ',$style)" />
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="@*[translate(name(),$ucase,$lcase)='bordercolor']">
		<xsl:variable name="style" select="../@*[translate(name(),$ucase,$lcase)='style']" />
		<xsl:attribute name="style">
			<xsl:value-of select="concat('border-color: ',text(),'; ',$style)" />
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="@*[translate(name(),$ucase,$lcase)='bgcolor']">
		<xsl:variable name="style" select="../@*[translate(name(),$ucase,$lcase)='style']" />
		<xsl:attribute name="style">
			<xsl:value-of select="concat('background-color: ',text(),'; ',$style)" />
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="@*[translate(name(),$ucase,$lcase)='background']">
		<xsl:variable name="style" select="../@*[translate(name(),$ucase,$lcase)='style']" />
		<xsl:attribute name="style">
			<xsl:value-of select="concat('background-image: url(&quot;',text(),'&quot;); ',$style)" />
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="@*[translate(name(),$ucase,$lcase)='nowrap']">
		<xsl:variable name="style" select="../@*[translate(name(),$ucase,$lcase)='style']" />
		<xsl:attribute name="style">
			<xsl:value-of select="concat('white-space: nowrap; ',$style)" />
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="*[translate(local-name(),$ucase,$lcase)='form' and translate(namespace-uri(),$ucase,$lcase)=$tap]">
		<xsl:variable name="formname" select="normalize-space(@*[translate(local-name(),$ucase,$lcase)='name'])" />
		<xsl:variable name="errorid" select="concat('tap_formerrors_',$formname,'_',generate-id())" />
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:if test="not(@*[translate(local-name(),$ucase,$lcase)='validateonevent' and translate(namespace-uri(),$ucase,$lcase)=$tap])">
				<xsl:attribute name="tap:validateonevent"><xsl:value-of select="'onchange,onblur'" /></xsl:attribute>
			</xsl:if>
			
			<xsl:choose>
				<xsl:when test="count(./*[translate(local-name(),$ucase,$lcase)='formhighlight' and translate(namespace-uri(),$ucase,$lcase)=$tap])!=0">
				<xsl:for-each select="*[translate(local-name(),$ucase,$lcase)='formhighlight' and translate(namespace-uri(),$ucase,$lcase)=$tap]">
				<xsl:copy-of select="." /></xsl:for-each></xsl:when>
				<xsl:otherwise><tap:formhighlight /></xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="count(./tap:formrequiredlabel)!=0">
				<xsl:copy-of select="tap:formrequiredlabel" /></xsl:when>
				<xsl:otherwise><tap:formrequiredlabel event="close" /></xsl:otherwise>
			</xsl:choose>
			
			<xsl:for-each select="*[translate(local-name(),$ucase,$lcase)='event' 
			and translate(normalize-space(namespace-uri()),$ucase,$lcase)=$tap]">
				<xsl:copy-of select="." />
			</xsl:for-each>
			<xsl:for-each select="*[translate(local-name(),$ucase,$lcase)='input' 
			and translate(normalize-space(@*[translate(local-name(),$ucase,$lcase)='type']),$ucase,$lcase)='hidden']">
				<xsl:copy-of select="." />
			</xsl:for-each>
			
			<table class="tap_form" align="{@*[translate(local-name(),$ucase,$lcase)='align']}">
				<col class="tap_formlabel" />
				<col class="tap_forminput" />
				
				<tbody><xsl:apply-templates mode="tapform" /></tbody>
				
				<tfoot>
					<tr>
						<td colspan="2" class="tap_formbutton">
							<xsl:for-each select="*[translate(local-name(),$ucase,$lcase)='button' or (translate(local-name(),$ucase,$lcase)='input' 
							and contains($buttons,concat(',',translate(@*[translate(local-name(),$ucase,$lcase)='type'],$ucase,$lcase),',')))]">
								<xsl:copy-of select="." />
							</xsl:for-each>
						</td>
					</tr>
				</tfoot>
			</table>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*" mode="tapform">
		<xsl:variable name="node" select="translate(local-name(),$ucase,$lcase)" />
		<xsl:variable name="type" select="concat(',',translate(normalize-space(@*[translate(local-name(),$ucase,$lcase)='type']),$ucase,$lcase),',')" />
		<xsl:variable name="nsuri" select="translate(normalize-space(namespace-uri()),$ucase,$lcase)" />
		<xsl:choose>
			<xsl:when test="$node='tr'"><xsl:copy-of select="." /></xsl:when>
			<xsl:when test="$node='button' or ($node='input' and contains($typelist,$type))" />
			<xsl:when test="$node='event' and $nsuri=$tap" />
			<xsl:when test="$node='select' or $node='textarea' or ($node='input' and ($type=',,' or not(contains($typelist,$type))))">
				<xsl:variable name="name" select="normalize-space(@*[translate(local-name(),$ucase,$lcase)='name'])" />
				<xsl:variable name="label" select="normalize-space(@*[translate(local-name(),$ucase,$lcase)='label'])" />
				<xsl:variable name="hint" select="normalize-space(@*[translate(local-name(),$ucase,$lcase)='hint'])" />
				<xsl:variable name="inputlabel" select="concat('tap_label.',$name,'_',generate-id())" />
				<tr>
					<xsl:element name="td">
						<xsl:attribute name="tap:variable"><xsl:value-of select="$inputlabel" /></xsl:attribute>
						<tap:text><xsl:value-of select="$label" /></tap:text>
					</xsl:element>
					<td>
						<xsl:copy>
							<xsl:copy-of select="@*" />
							<xsl:attribute name="tap:label">
								<xsl:value-of select="$inputlabel" />
							</xsl:attribute>
							
							<xsl:apply-templates />
							
							<xsl:call-template name="requiredinput" />
						</xsl:copy>
						<xsl:if test="string-length($hint)!=0">
							<div class="tap_formhint" tap:notext="true">
								<tap:text><xsl:value-of select="$hint" /></tap:text>
							</div>
						</xsl:if>
					</td>
				</tr>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="@*" />
					<xsl:apply-templates mode="tapform" />
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*[translate(local-name(),$ucase,$lcase)='formgroup' and translate(namespace-uri(),$ucase,$lcase)=$tap]" mode="tapform">
		<xsl:variable name="inputlabel">
			<xsl:value-of select="concat('tap_label.group_',generate-id())" />
		</xsl:variable>
		<tr>
			<xsl:element name="td">
				<xsl:attribute name="tap:variable">
					<xsl:value-of select="$inputlabel" />
				</xsl:attribute>
				<tap:text><xsl:value-of select="normalize-space(@*[translate(local-name(),$ucase,$lcase)='label'])" /></tap:text>
			</xsl:element>
			<td>
				<table border="0" cellpadding="0" cellspacing="0">
					<tr class="tap_formgroup">
						<xsl:apply-templates mode="tapformgroup" />
					</tr>
				</table>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="*" mode="tapformgroup">
		<xsl:variable name="node" select="translate(local-name(),$ucase,$lcase)" />
		<xsl:variable name="type" select="concat(',',translate(normalize-space(@*[translate(local-name(),$ucase,$lcase)='type']),$ucase,$lcase),',')" />
		<xsl:choose>
			<xsl:when test="$node='button' or ($node='input' and contains($typelist,$type))" />
			<xsl:when test="$node='select' or $node='textarea' or ($node='input' and ($type=',,' or not(contains($typelist,$type))))">
				<xsl:variable name="name" select="normalize-space(@*[translate(local-name(),$ucase,$lcase)='name'])" />
				<xsl:variable name="label" select="normalize-space(@*[translate(local-name(),$ucase,$lcase)='label'])" />
				<xsl:variable name="grouplabel" select="concat('tap_label.group_',generate-id(ancestor::*[translate(local-name(),$ucase,$lcase)='formgroup' and namespace-uri()=$tap]))" />
				<xsl:variable name="inputlabel" select="concat('tap_label_input_',$name,'_',generate-id())" />
				<xsl:variable name="clickable" select="',radio,check,checkbox,'" />
				<xsl:variable name="hint" select="normalize-space(@*[translate(local-name(),$ucase,$lcase)='hint'])" />
				<xsl:element name="td">
					<xsl:if test="string-length($label)!=0 and contains($clickable,$type)">
						<span class="tap_formgroupradiolabel">
							<xsl:attribute name="id">
								<xsl:value-of select="$inputlabel" />
							</xsl:attribute>
							<xsl:value-of select="$label" />
						</span>
					</xsl:if>
					
					<xsl:copy>
						<xsl:copy-of select="@*" />
						
						<xsl:attribute name="tap:label">
							<xsl:choose>
								<xsl:when test="string-length($label)!=0">
									<xsl:value-of select="concat($grouplabel,',',$inputlabel)" />
								</xsl:when>
								<xsl:otherwise><xsl:value-of select="$grouplabel" /></xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						
						<xsl:apply-templates mode="tapformgroup" />
						
						<xsl:call-template name="requiredinput" />
					</xsl:copy>
					<xsl:choose>
						<xsl:when test="string-length($label)!=0 and not(contains($clickable,$type))">
							<span class="tap_formgrouplabel">
								<xsl:attribute name="id">
									<xsl:value-of select="$inputlabel" />
								</xsl:attribute>
								<xsl:value-of select="$label" />
							</span>
							
							<xsl:if test="string-length($hint)!=0">
								<span class="tap_formhint" tap:notext="true">
									<tap:text><xsl:value-of select="concat('(',$hint,')')" /></tap:text>
								</span>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="string-length($hint)!=0">
								<div class="tap_formhint" tap:notext="true">
									<tap:text><xsl:value-of select="$hint" /></tap:text>
								</div>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="@*" />
					<xsl:apply-templates mode="tapformgroup" />
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*[
		translate(namespace-uri(),$ucase,$lcase)=$tap and 
		( 
			translate(local-name(),$ucase,$lcase)='required' or 
			(
				translate(local-name(),$ucase,$lcase)='validate' and 
				translate(@*[translate(name(),$ucase,$lcase)],$ucase,$lcase)='required' 
			)
		)]">
		<xsl:choose>
			<xsl:when test="./*">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*[
	translate(namespace-uri(),$ucase,$lcase)=$tap and 
	translate(local-name(),$ucase,$lcase)='validate']">
		<xsl:variable name="type" select="translate(@*[translate(name(),$ucase,$lcase)='type'],$ucase,$lcase)" />

		<xsl:choose>
			<xsl:when test="./* and ($type='numeric' or $type='date' or $type='length')">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*[
		translate(local-name(),$ucase,$lcase)='select' or 
		translate(local-name(),$ucase,$lcase)='textarea' or 
			(
			translate(local-name(),$ucase,$lcase)='input' and 
				( 
				string-length(@*[translate(local-name(),$ucase,$lcase)='type'])=0 
				or not(contains($typelist,translate(concat(',',local-name(),','),$ucase,$lcase)))
				) 
			) 
		]">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates />
			<xsl:call-template name="requiredinput" />
			<xsl:call-template name="validinput" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template name="requiredinput">
		<xsl:variable name="requirement" select="ancestor::*[
			translate(namespace-uri(),$ucase,$lcase)=$tap and 
			(
				translate(local-name(),$ucase,$lcase)='required' or 
				(
					translate(local-name(),$ucase,$lcase)='validate' and 
					translate(@*[translate(name(),$ucase,$lcase)='type'],$ucase,$lcase)='required'
				) 
			) 
		][1]" />
		
		<xsl:if test="$requirement">
			<xsl:variable name="type" select="translate(@*[translate(local-name(),$ucase,$lcase)='type'],$ucase,$lcase)" />
			<xsl:variable name="req" select="translate(@*[translate(local-name(),$ucase,$lcase)='required' and translate(namespace-uri(),$ucase,$lcase)=$tap],$ucase,$lcase)" />
			<xsl:variable name="bool" select="translate(@*[translate(local-name(),$ucase,$lcase)='boolean' and translate(namespace-uri(),$ucase,$lcase)=$tap],$ucase,$lcase)" />
			
			<xsl:if test="string-length($req)=0 or ($req!='false' and $req!='no' and $req!='0')">
				<xsl:if test="($type!='check' and $type!='checkbox') or string-length($bool)=0 or $bool='false' or $bool='0' or $bool='no'">
					<xsl:element name="{name($requirement)}">
						<xsl:copy-of select="$requirement/@*" />
					</xsl:element>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="validinput">
		<xsl:variable name="node" select="translate(local-name(),$ucase,$lcase)" />
		
		<xsl:if test="$node='input' or $node='textarea'">
			<xsl:variable name="type" select="translate(@*[translate(local-name(),$ucase,$lcase)='type'],$ucase,$lcase)" />
			
			<xsl:if test="string-length($type)=0 or 
			($type!='check' and $type!='checkbox' and $type!='radio' 
			and $type!='button' and $type!='reset' and $type!='submit')">
				<xsl:for-each select="ancestor::*[translate(local-name(),$ucase,$lcase)='validate']">
					<xsl:variable name="validate" select="translate(@*[translate(name(),$ucase,$lcase)='type'],$ucase,$lcase)" />
					
					<xsl:if test="$validate='numeric' or $validate='date' or $validate='length'">
						<xsl:copy>
							<xsl:copy-of select="@*" />
						</xsl:copy>
					</xsl:if>
				</xsl:for-each>
			</xsl:if>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
