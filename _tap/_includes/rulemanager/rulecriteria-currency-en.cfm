name=Money
actionnumber=Amount
percentage=percent
adjustment=plus
adjustmentgroup=Or
compnumber=Of Value
literalnumber=Amount 
format_eq=is equal to
format_gte=is no less than
format_lte=is no more than
format_gt=is greater than
format_lt=is less than
percentof=<xsl:value-of select="concat(' ',$percentamount,' of ')" />
adjustformat=<xsl:choose><xsl:when test="number(@adjustment) &gt; 0">+</xsl:when><xsl:when test="number(@adjustment) &lt; 0">-</xsl:when></xsl:choose><xsl:value-of select="$adjustmentamount" />
describe=<xsl:value-of select="concat($actionnumber,' ',$format,$percentage,' ',$compnumber,' ',$adjustment)" />