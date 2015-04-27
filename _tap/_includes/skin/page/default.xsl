<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />
	
	<xsl:param name="offset" select="3" />
	<xsl:param name="zero" />
	<xsl:param name="one" />
	<xsl:param name="all" />
	<xsl:param name="range" />
	<xsl:param name="pageprefix" />
	<xsl:param name="pagesuffix" />
	<xsl:param name="overflowleft" />
	<xsl:param name="overflowright" />
	<xsl:param name="rpp_title" />
	<xsl:param name="rpp_option" />
	<xsl:param name="showall" />
	<xsl:param name="overflowtitle" />
	
	<xsl:variable name="pagevariable" select="/pagelist/@variable" />
	<xsl:variable name="optvariable" select="/pagelist/options/@variable" />
	<xsl:variable name="pagesize" select="/pagelist/@pagesize" />
	<xsl:variable name="numpages" select="count(/pagelist/page)" />
	<xsl:variable name="showpages" select="1 + (2 * $offset)" />
	<xsl:variable name="page" select="/pagelist/@page" />
	<xsl:variable name="startrow" select="/pagelist/@startrow" />
	<xsl:variable name="endrow" select="/pagelist/@endrow" />
	
	<xsl:variable name="startpage">
		<xsl:choose>
			<xsl:when test="$numpages &lt;= $showpages">1</xsl:when>
			
			<xsl:when test="$page &gt; ($numpages - $offset)">
				<xsl:value-of select="1 + $numpages - $showpages" />
			</xsl:when>
			
			<xsl:when test="$page &gt; $offset">
				<xsl:value-of select="$page - $offset" />
			</xsl:when>
			
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="endpage" select="$startpage + $showpages -1" />
	
	<xsl:template name="crlf">
		<xsl:text disable-output-escaping="yes">&#13;&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="/pagelist">
		<div class="pages" id="{@id}">
			<xsl:call-template name="totals" />
			
			<xsl:choose>
				<xsl:when test="count(page) &gt; 1">
					<span class="pagelist">
						<xsl:value-of select="/pagelist/open/text()" disable-output-escaping="yes" />
						<xsl:call-template name="pageprefix" />
						
						<span class="fixForIERelativePositionBug">
							<xsl:call-template name="overflow">
								<xsl:with-param name="label" select="$overflowleft" />
								<xsl:with-param name="pages" select="page[position() &lt; $startpage]" />
								<xsl:with-param name="class" select="'previous'" />
							</xsl:call-template>
							<!-- don't let the style sheet collapse this span tag -->
							<xsl:text> </xsl:text>
						</span>
						
						<span class="pageoffset">
							<xsl:for-each select="page[position() &gt;= $startpage and position() &lt;= $endpage]">
								<xsl:if test="position() &gt; 1">
									<xsl:value-of select="/pagelist/childdelimiter/text()" disable-output-escaping="yes" />
								</xsl:if>
								<xsl:apply-templates select="." />
							</xsl:for-each>
						</span>
						
						<span class="fixForIERelativePositionBug">
							<xsl:call-template name="overflow">
								<xsl:with-param name="label" select="$overflowright" />
								<xsl:with-param name="pages" select="page[position() &gt; $endpage]" />
								<xsl:with-param name="class" select="'next'" />
							</xsl:call-template>
							
							<xsl:call-template name="pagesuffix" />
							<xsl:value-of select="/pagelist/close/text()" disable-output-escaping="yes" />
							
							<xsl:apply-templates select="options" />
						</span>
					</span>
				</xsl:when>
				<xsl:otherwise>
					<span class="fixForIERelativePositionBug">
						<xsl:apply-templates select="options" />
					</span>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<xsl:template name="pageprefix">
		<xsl:if test="string-length($pageprefix)!=0">
			<span class="pageprefix"><xsl:value-of select="$pageprefix" /></span>
		</xsl:if>
	</xsl:template>

	<xsl:template name="pagesuffix">
		<xsl:if test="string-length($pagesuffix)!=0">
			<span class="pagesuffix"><xsl:value-of select="$pagesuffix" /></span>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="overflow">
		<xsl:param name="label" />
		<xsl:param name="pages" />
		<xsl:param name="class" />
		
		<xsl:choose>
			<xsl:when test="count($pages)=1">
				<xsl:apply-templates select="$pages" />
			</xsl:when>
			
			<xsl:when test="count($pages)!=0">
				<span class="pageoverflow {$class}">
					<a class="overflow" href="javascript:void(0);" title="{$overflowtitle}" 
					onclick="this.parentNode.getElementsByTagName('span')[0].style.display='block';">
						<xsl:value-of select="$label" disable-output-escaping="yes" />
					</a>
					<span class="overflow" style="display:none;">
						<xsl:attribute name="onmouseout">if (isMouseOut(event,this,{className:'overflow'})) { this.style.display='none'; }</xsl:attribute>
						<xsl:choose>
							<xsl:when test="$class='previous'">
								<xsl:for-each select="$pages">
									<xsl:sort data-type="number" order="descending" select="position()" />
									<xsl:apply-templates select="." />
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$pages" />
							</xsl:otherwise>
						</xsl:choose>
					</span>
				</span>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="totals">
		<span class="pagecount">
			<xsl:choose>
				<xsl:when test="@rows = 0">
					<span class="nopages"><xsl:value-of select="$zero" /></span>
				</xsl:when>
				
				<xsl:when test="@rows = 1">
					<span class="onepage">
						<xsl:value-of select="substring-before($one,'|')" />
						<span class="number"><xsl:value-of select="normalize-space(startrow/text())" /></span>
						<xsl:value-of select="substring-after($one,'|')" />
					</span>
				</xsl:when>
				
				<xsl:when test="@startrow = 1 and @endrow &gt;= @rows">
					<span class="allpages">
						<xsl:value-of select="substring-before($all,'|')" />
						<span class="number"><xsl:value-of select="normalize-space(rows/text())" /></span>
						<xsl:value-of select="substring-after($all,'|')" />
					</span>
				</xsl:when>
				
				<xsl:otherwise>
					<xsl:variable name="before" select="substring-before($range,'|')" />
					<xsl:variable name="rest" select="substring-after($range,'|')" />
					<xsl:variable name="delimiter" select="substring-before($rest,'|')" />
					<xsl:variable name="rest2" select="substring-after($rest,'|')" />
					<xsl:variable name="of" select="substring-before($rest2,'|')" />
					<xsl:variable name="records" select="substring-after($rest2,'|')" />
					
					<span class="pagerange">
						<span class="number"><xsl:value-of select="normalize-space(startrow/text())" /></span>
						<xsl:if test="$startrow != $endrow">
							<xsl:value-of select="$delimiter" />
							<span class="number"><xsl:value-of select="normalize-space(endrow/text())" /></span>
						</xsl:if>
						<xsl:value-of select="$of" />
						<span class="number"><xsl:value-of select="normalize-space(rows/text())" /></span>
						<xsl:value-of select="$records" />
					</span>
				</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>
	
	<xsl:template match="page">
		<xsl:value-of select="/pagelist/prechild/text()" disable-output-escaping="yes" />
		<a class="{@class}" href="{@href}&amp;{$pagevariable}={@index}&amp;{$optvariable}={$pagesize}">
			<xsl:call-template name="events" />
			<xsl:apply-templates />
		</a>
		<xsl:value-of select="/pagelist/postchild/text()" disable-output-escaping="yes" />
	</xsl:template>
	
	<xsl:template name="events">
		<xsl:variable name="pageid" select="/pagelist/@id" />
		<xsl:variable name="collapse">if (this.parentNode.className.search(/rpp_optionlist|overflow/)==0) { this.parentNode.style.display='none'; } </xsl:variable>
		
		<xsl:attribute name="onclick">
			<xsl:value-of select="$collapse" />
			<xsl:if test="/pagelist/events/click">document.getElementById('<xsl:value-of select="$pageid" />').href = this.href; return <xsl:value-of select="$pageid" />_click(event);</xsl:if>
		</xsl:attribute>
		
		<xsl:for-each select="/pagelist/events/*[name()!='click']">
			<xsl:attribute name="on{name()}">return <xsl:value-of select="$pageid" />_<xsl:value-of select="name()" />(event);</xsl:attribute>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="options">
		<xsl:variable name="href" select="@href" />
		<xsl:variable name="varname" select="@variable" />
		<xsl:variable name="prefix" select="substring-before($rpp_option,'|')" />
		<xsl:variable name="suffix" select="substring-after($rpp_option,'|')" />
		
		<xsl:if test="string-length(@src)!=0">
			<span class="resultsperpage">
				<span class="rpp_optionlist">
					<xsl:attribute name="onmouseout">if (isMouseOut(event,this,{className:'rpp_optionlist'})) { this.style.display='none'; }</xsl:attribute>
					<xsl:for-each select="opt">
						<a href="{$href}&amp;{$varname}={@value}&amp;{$pagevariable}=1">
							<xsl:call-template name="events" />
							
							<xsl:choose>
								<xsl:when test="@value=0">
									<xsl:value-of select="$showall" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$prefix" />
									<span class="number"><xsl:apply-templates /></span>
									<xsl:value-of select="$suffix" />
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</xsl:for-each>
				</span>
				<img class="rpp" src="{@src}" alt="{$rpp_title}" title="{$rpp_title}" 
					onmouseover="this.src='{@hover}';" onmouseout="this.src='{@src}';" 
					onclick="this.parentNode.getElementsByTagName('span')[0].style.display='block';" />
			</span>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>