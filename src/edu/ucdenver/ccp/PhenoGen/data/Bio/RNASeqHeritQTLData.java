package edu.ucdenver.ccp.PhenoGen.data.Bio;

import java.util.HashMap;

public class RNASeqHeritQTLData {
        private String phenogenID="";
        private HashMap<String,Double> herit=new HashMap();
        private HashMap<String,Integer> countQTL=new HashMap();
        private HashMap<String,String> maxQTL=new HashMap();

        public RNASeqHeritQTLData(String phenogenID){
            this.phenogenID=phenogenID;
        }

        public void addHerit(String tissue,double herit){
            this.herit.put(tissue,herit);
        }

        public void addCount(String tissue,double pvalue,String location){
            if(countQTL.containsKey(tissue)){
                int tmp=countQTL.get(tissue);
                tmp++;
                countQTL.put(tissue,tmp);
                String tmpMax=maxQTL.get(tissue);
                double tmpPval=Double.parseDouble(tmpMax.substring(0,tmpMax.indexOf(":")));
                if(tmpPval<pvalue){
                    maxQTL.put(tissue,pvalue+":"+location);
                }
            }else{
                countQTL.put(tissue,1);
                maxQTL.put(tissue,pvalue+":"+location);
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

        public String getMaxQTL(String tissue){
            String ret="";
            if(maxQTL.containsKey(tissue)){
                ret=maxQTL.get(tissue);
            }
            return ret;
        }
        public int getQTLCount(String tissue){
            int ret=0;
            if(countQTL.containsKey(tissue)){
                ret=countQTL.get(tissue);
            }
            return ret;
        }

}
