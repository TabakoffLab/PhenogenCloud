<form id="snp_browser_form" >
    <input type="hidden" name="first_run" value="true">
    <div  class="GNColumn">
        <div  class="GNRow">
            <label for="snp_or_indel" class="GNLeftDiv" ><b>Type:</b></label>
            <div class="GNRightDiv" >
                <select name="variant">
                    <option value="SNP" selected="">SNP</option>
                    <option value="InDel">InDel</option>
                </select>
            </div>
        </div>
        <div  class="GNRow">
            <label for="species" class="GNLeftDiv" ><b>Species:</b></label>
            <div class="GNRightDiv">
                <select id="species_select" name="species">
                    <option value="Mouse" >Mouse</option>
                    <option value="Rat" selected>Rat</option>
                    <!--<option value="Human" disabled="">Human</option>-->
                </select>
            </div>
        </div>
        <div  class="GNRow">
            <label for="gene_or_id" class="GNLeftDiv" ><b>Gene or ID:</b></label>
            <div class="GNRightDiv">
                <span  style="position: relative; display: inline-block;"><input type="text" size="12" value=""  readonly="" autocomplete="off" spellcheck="false" tabindex="-1" dir="ltr" style="position: absolute; top: 0px; left: 0px; border-color: transparent; box-shadow: none; opacity: 1; background: none 0% 0% / auto repeat scroll padding-box border-box rgb(255, 255, 255);"><input type="text" name="gene_name" size="12" value="" class="tt-input" autocomplete="off" spellcheck="false" dir="auto" style="position: relative; vertical-align: top; background-color: rgba(0, 0, 0, 0);"><pre aria-hidden="true" style="position: absolute; visibility: hidden; white-space: pre; font-family: &quot;Helvetica Neue&quot;, Helvetica, Arial, sans-serif; font-size: 14px; font-style: normal; font-variant: normal; font-weight: 400; word-spacing: 0px; letter-spacing: 0px; text-indent: 0px; text-rendering: auto; text-transform: none;"></pre><div class="tt-menu" style="position: absolute; top: 100%; left: 0px; z-index: 100; display: none;"><div class="tt-dataset tt-dataset-rn6-genes"></div></div></span>
            </div>
        </div>
        <div class="GNRow">
            <div style="text-align: center;"><b><font color="red">Or select</font></b></div>
        </div>
        <div  class="GNRow">
            <label for="chr" class="GNLeftDiv" <b>Chr:</b></label>
            <div class="GNRightDiv">
                <select id="chr_select" name="chr">
                    <option value="1">1</option>
                    <option value="2">2</option>
                    <option value="3">3</option>
                    <option value="4">4</option>
                    <option value="5">5</option>
                    <option value="6">6</option>
                    <option value="7">7</option>
                    <option value="8">8</option>
                    <option value="9">9</option>
                    <option value="10">10</option>
                    <option value="11">11</option>
                    <option value="12">12</option>
                    <option value="13">13</option>
                    <option value="14">14</option>
                    <option value="15">15</option>
                    <option value="16">16</option>
                    <option value="17">17</option>
                    <option value="18">18</option>
                    <option value="19" selected="">19</option>
                    <option value="20" selected="">20</option>
                    <option value="X">X</option>

                </select>
            </div>
        </div>
        <div  class="GNRow">
            <label for="start_mb" class="GNLeftDiv"><b>Mb:</b></label>
            <div class="GNRightDiv">
                <input type="text" name="start_mb" size="10" value="">
            </div>
        </div>
        <div class="GNRow">
            <label for="end_mb" class="GNLeftDiv" >to</label>
            <div class="GNRightDiv" >
                <input type="text" name="end_mb" size="10" value="">
            </div>
        </div>
        <hr>
        <div class="GNRow">
            <label ></label>
            <div >
                <input type="button" class="GNButton" onClick="linkToGN2()" value="Run Search on GeneNetwork">
            </div>
        </div>
    </div>
    <div  class="GNColumn">
        <div  class="GNRow">
            <label for="strains" class="GNLeftDiv"><b>Strains:</b></label>
            <div  class="GNRightDiv">
                <select id="strain_select" name="strains" style="width:43%;">
                    <%if(myOrganism.equals("Mm")){%>
                    <option value="129P2/OlaHsd" selected="">129P2/OlaHsd</option>
                    <option value="129S1/SvImJ">129S1/SvImJ</option>
                    <option value="129S5/SvEvBrd">129S5/SvEvBrd</option>
                    <option value="AKR/J">AKR/J</option>
                    <option value="A/J">A/J</option>
                    <option value="BALB/cJ">BALB/cJ</option>

                    <option value="C3H/HeJ">C3H/HeJ</option>

                    <option value="C57BL/6J">C57BL/6J</option>

                    <option value="CAST/EiJ">CAST/EiJ</option>

                    <option value="CBA/J">CBA/J</option>

                    <option value="DBA/2J">DBA/2J</option>

                    <option value="LP/J">LP/J</option>

                    <option value="NOD/ShiLtJ">NOD/ShiLtJ</option>

                    <option value="NZO/HlLtJ">NZO/HlLtJ</option>

                    <option value="PWK/PhJ">PWK/PhJ</option>

                    <option value="SPRET/EiJ">SPRET/EiJ</option>

                    <option value="WSB/EiJ">WSB/EiJ</option>

                    <option value="PWD/PhJ">PWD/PhJ</option>

                    <option value="SJL/J">SJL/J</option>

                    <option value="NZL/LtJ">NZL/LtJ</option>

                    <option value="CZECHII/EiJ">CZECHII/EiJ</option>

                    <option value="CALB/RkJ">CALB/RkJ</option>

                    <option value="ST/bJ">ST/bJ</option>

                    <option value="ISS/IbgTejJ">ISS/IbgTejJ</option>

                    <option value="C57L/J">C57L/J</option>

                    <option value="Qsi5">Qsi5</option>

                    <option value="B6A6_Esline_Regeneron">B6A6_Esline_Regeneron</option>

                    <option value="129T2/SvEmsJ">129T2/SvEmsJ</option>

                    <option value="BALB/cByJ">BALB/cByJ</option>

                    <option value="NZB/BlNJ">NZB/BlNJ</option>

                    <option value="P/J">P/J</option>

                    <option value="I/LnJ">I/LnJ</option>

                    <option value="PERC/EiJ">PERC/EiJ</option>

                    <option value="TALLYHO/JngJ">TALLYHO/JngJ</option>

                    <option value="CE/J">CE/J</option>

                    <option value="MRL/MpJ">MRL/MpJ</option>

                    <option value="PERA/EiJ">PERA/EiJ</option>

                    <option value="IS/CamRkJ">IS/CamRkJ</option>

                    <option value="ZALENDE/EiJ">ZALENDE/EiJ</option>

                    <option value="Fline">Fline</option>

                    <option value="BTBRT<+>tf/J">BTBRT&lt;+&gt;tf/J</option>

                    <option value="O20">O20</option>

                    <option value="C58/J">C58/J</option>

                    <option value="BPH/2J">BPH/2J</option>

                    <option value="DDK/Pas">DDK/Pas</option>

                    <option value="C57BL/6NHsd">C57BL/6NHsd</option>

                    <option value="C57BL/6NTac">C57BL/6NTac</option>

                    <option value="129S4/SvJae">129S4/SvJae</option>

                    <option value="BPL/1J">BPL/1J</option>

                    <option value="BPN/3J">BPN/3J</option>

                    <option value="PL/J">PL/J</option>

                    <option value="DBA/1J">DBA/1J</option>

                    <option value="MSM/Ms">MSM/Ms</option>

                    <option value="MA/MyJ">MA/MyJ</option>

                    <option value="NZW/LacJ">NZW/LacJ</option>

                    <option value="C57BL/10J">C57BL/10J</option>

                    <option value="C57BL/6ByJ">C57BL/6ByJ</option>

                    <option value="RF/J">RF/J</option>

                    <option value="C57BR/cdJ">C57BR/cdJ</option>

                    <option value="129S6/SvEv">129S6/SvEv</option>

                    <option value="MAI/Pas">MAI/Pas</option>

                    <option value="RIIIS/J">RIIIS/J</option>

                    <option value="C57BL/6NNIH">C57BL/6NNIH</option>

                    <option value="FVB/NJ">FVB/NJ</option>

                    <option value="SEG/Pas">SEG/Pas</option>

                    <option value="MOLF/EiJ">MOLF/EiJ</option>

                    <option value="C3HeB/FeJ">C3HeB/FeJ</option>

                    <option value="Lline">Lline</option>

                    <option value="SKIVE/EiJ">SKIVE/EiJ</option>

                    <option value="C57BL/6NCrl">C57BL/6NCrl</option>

                    <option value="KK/HlJ">KK/HlJ</option>

                    <option value="LG/J">LG/J</option>

                    <option value="C57BLKS/J">C57BLKS/J</option>

                    <option value="SM/J">SM/J</option>

                    <option value="NOR/LtJ">NOR/LtJ</option>

                    <option value="ILS/IbgTejJ">ILS/IbgTejJ</option>

                    <option value="C57BL/6JOlaHsd">C57BL/6JOlaHsd</option>

                    <option value="SWR/J">SWR/J</option>

                    <option value="C57BL/6JBomTac">C57BL/6JBomTac</option>

                    <option value="SOD1/EiJ">SOD1/EiJ</option>

                    <option value="NON/LtJ">NON/LtJ</option>

                    <option value="JF1/Ms">JF1/Ms</option>

                    <option value="129X1/SvJ">129X1/SvJ</option>

                    <option value="C2T1_Esline_Nagy">C2T1_Esline_Nagy</option>

                    <option value="C57BL/6NJ">C57BL/6NJ</option>

                    <option value="LEWES/EiJ">LEWES/EiJ</option>

                    <option value="RBA/DnJ">RBA/DnJ</option>

                    <option value="DDY/JclSidSeyFrkJ">DDY/JclSidSeyFrkJ</option>

                    <option value="SEA/GnJ">SEA/GnJ</option>

                    <option value="C57BL/6JCrl">C57BL/6JCrl</option>

                    <option value="EL/SuzSeyFrkJ">EL/SuzSeyFrkJ</option>

                    <option value="HTG/GoSfSnJ">HTG/GoSfSnJ</option>

                    <option value="129S2/SvHsd">129S2/SvHsd</option>

                    <option value="MOLG/DnJ">MOLG/DnJ</option>

                    <option value="BUB/BnJ">BUB/BnJ</option>
                    <%}else{%>

                    <option value="F344">F344</option>
                    <option value="ACI">ACI</option>
                    <option value="BBDP">BBDP</option>
                    <option value="FHH">FHH</option>
                    <option value="FHL">FHL</option>
                    <option value="GK">GK</option>
                    <option value="LE">LE</option>
                    <option value="LEW">LEW</option>
                    <option value="LH">LH</option>
                    <option value="LL">LL</option>
                    <option value="LN">LN</option>
                    <option value="MHS">MHS</option>
                    <option value="MNS">MNS</option>
                    <option value="SBH">SBH</option>
                    <option value="SBN">SBN</option>
                    <option value="SHR">SHR</option>
                    <option value="SHRSP">SHRSP</option>
                    <option value="SR">SR</option>
                    <option value="SS">SS</option>
                    <option value="WAG">WAG</option>
                    <option value="WLI">WLI</option>
                    <option value="WMI">WMI</option>
                    <option value="WKY">WKY</option>
                    <option value="BN">BN</option>
                    <%}%>


                </select>
                <div style="float: right; line-height: 20px;display:inline-block;">
                    <input type="button" name="add_strain" value="Add" class="GNButton" style="vertical-align: middle;">
                </div>
            </div>
        </div>
        <div class="GNRow">
            <label for="chosen_strains_select" class="GNLeftDiv" ><b><font color="red">Limit to:</font></b> <input type="checkbox" name="limit_strains" checked="" size="100"></label>
            <div class="GNRightDiv">
                <select id="chosen_strains_select" size="11" style="width: 70%;float:left;">
                    <option value="F344">F344</option>
                    <option value="ACI">ACI</option>
                    <option value="LE">LE</option>
                    <option value="LEW">LEW</option>
                    <option value="SHR">SHR</option>
                    <option value="SHRSP">SHRSP</option>
                    <option value="SR">SR</option>
                    <option value="SS">SS</option>
                    <option value="WKY">WKY</option>
                </select>
                <div style="float: right; line-height: 189px;">
                    <input  class="GNButton" type="button" name="remove_strain" value="Cut" style="vertical-align: middle;float:left;">
                </div>
            </div>
        </div>
    </div>
    <div  class="GNColumn">
        <div  class="GNrow">
            <label for="domain" class="GNLeftDiv" style="padding-bottom: 0px;" ><b>Domain:</b></label>
            <div class="GNRightDiv" style="padding-bottom: 0px;">
                <select name="domain" size="4">
                    <option value="All" selected="">All</option>
                    <option value="Exon">Exon</option>
                    <option value="5' UTR">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5' UTR</option>
                    <option value="Coding">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Coding Region</option>
                    <option value="3' UTR">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3' UTR</option>
                    <option value="Intron">Intron</option>
                    <option value="Splice Site">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Splice Site</option>
                    <option value="Nonsplice Site">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nonsplice Site</option>
                    <option value="Upstream">Upstream</option>
                    <option value="Downstream">Downstream</option>
                    <option value="Intergenic">Intergenic</option>
                </select>
            </div>
        </div>
        <div  class="GNrow">
            <label for="function" class="GNLeftDiv" style="padding-bottom: 0px;"><b>Function:</b></label>
            <div class="GNRightDiv" style="padding-bottom: 0px;">
                <select name="function" size="3">
                    <option value="All" selected="">All</option>
                    <option value="Nonsynonymous">Nonsynonymous</option>
                    <option value="Synonymous">Synonymous</option>
                    <option value="Start Gained">Start Gained</option>
                    <option value="Start Lost">Start Lost</option>
                    <option value="Stop Gained">Stop Gained</option>
                    <option value="Stop Lost">Stop Lost</option>
                </select>
            </div>
        </div>
        <div  class="GNrow">
            <label for="source" class="GNLeftDiv" ><b>Source:</b></label>
            <div class="GNRightDiv">
                <select name="source">
                    <option value="All" selected="">All</option>
                    <option value="None">None</option>
                    <option value="dbSNP">dbSNP</option>
                    <option value="dbSNP (release 149)">dbSNP (release 149)</option>
                    <option value="Sanger/UCLA">Sanger/UCLA</option>
                    <option value="UTHSC_CITG">UTHSC_CITG</option>
                </select>
            </div>
        </div>
        <div >
            <label for="criteria" class="GNLeftDiv" ><b>ConScore:</b></label>
            <div class="GNRightDiv">
                <select name="criteria" size="1">
                    <option value=">=" selected="">&gt;=</option>
                    <option value="==">=</option>
                    <option value="<=">&lt;=</option>
                </select>
                <input type="text" name="score" value="0.0" size="5">
            </div>
        </div>
        <div  class="GNrow">
            <label class="GNLeftDiv" ><input type="checkbox" name="redundant"></label>
            <div class="GNRightDiv">
                Non-redundant SNP Only
            </div>
        </div>
        <div >
            <label class="GNLeftDiv" ><input type="checkbox" name="diff_alleles" ></label>
            <div class="GNRightDiv">
                Different Alleles Only
            </div>
        </div>
    </div>
</form>
