package edu.ucdenver.ccp.PhenoGen.data.Bio;

import java.util.HashMap;

public class RNASeqHeritQTLData {
        private String phenogenID="";
        private String ensemblID="";
        private HashMap<String,Double> herit=new HashMap<>();
        private HashMap<String,HashMap<String,String>> minTransQTL=new HashMap<>();
        private HashMap<String,HashMap<String,String>> minCisQTL=new HashMap<>();
        private HashMap<String,HashMap<String,Double>> tpm=new HashMap<>();

        public RNASeqHeritQTLData(String phenogenID,String ensemblID){
            this.phenogenID=phenogenID;
            this.ensemblID=ensemblID;
        }

        public String getPhenogenID() {return phenogenID;}
        public String getEnsemblID() {return ensemblID;}

        public void addHerit(String tissue,double herit){
            this.herit.put(tissue,herit);
        }

        public void addCount(String tissue,double pvalue,String location,boolean cis,String source){
            if(cis){
                if(minCisQTL.containsKey(tissue)){
                    HashMap<String,String> tmpSourceHM=minCisQTL.get(tissue);
                    if(tmpSourceHM.containsKey(source)){
                        String tmpMin=tmpSourceHM.get(source);
                        double tmpPval=Double.parseDouble(tmpMin.substring(0,tmpMin.indexOf(":")));
                        if(pvalue<tmpPval){
                            tmpSourceHM.put(source,pvalue+":"+location);
                        }
                    }else{
                        tmpSourceHM.put(source,pvalue+":"+location);
                    }
                }else{
                    HashMap<String,String> tmp = new HashMap<>();
                    tmp.put(source,pvalue+":"+location);
                    minCisQTL.put(tissue,tmp);
                }
            }else{
                if(minTransQTL.containsKey(tissue)){
                    HashMap<String,String> tmpSourceHM=minTransQTL.get(tissue);
                    if(tmpSourceHM.containsKey(source)){
                        String tmpMin=tmpSourceHM.get(source);
                        double tmpPval=Double.parseDouble(tmpMin.substring(0,tmpMin.indexOf(":")));
                        if(pvalue<tmpPval){
                            tmpSourceHM.put(source,pvalue+":"+location);
                        }
                    }else{
                        tmpSourceHM.put(source,pvalue+":"+location);
                    }

                }else{
                    HashMap<String,String> tmp = new HashMap<>();
                    tmp.put(source,pvalue+":"+location);
                    minTransQTL.put(tissue,tmp);
                }
            }


        }

        public String getID(){
            return this.phenogenID;
        }

        public double getHerit(String tissue){
            double ret=-1;
            if(herit.containsKey(tissue)){
                ret=herit.get(tissue);
            }
            return ret;
        }

        public String getMinTransQTL(String tissue,String source){
            String ret="";
            if(minTransQTL.containsKey(tissue)){
                ret=minTransQTL.get(tissue).get(source);
            }
            return ret;
        }
        public String getMinCisQTL(String tissue,String source){
            String ret="";
            if(minCisQTL.containsKey(tissue)){
                ret=minCisQTL.get(tissue).get(source);
            }
            return ret;
        }

}
