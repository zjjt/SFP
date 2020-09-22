package com.ubagroup.superfileprocessor.core.repository.oracle;

import java.util.List;

public class Queries {
    public static String getAccountStatus(List<Object> accountId){
        System.out.println("the accounts are "+accountId);
        String req="select foracid,g.acct_name,g.schm_code, CLR_bal_amt Solde,acct_status,schm_desc\r\n"+
                "from tbaadm.gam g,tbaadm.gsp g1,((select acid,acct_status from tbaadm.cam where acct_status\n" +
                "in ('D','I','A')) union (select acid,acct_status from tbaadm.smt where acct_status in ('D','I','A'))) z\r\n"+
                "where  z.acid = g.acid and g1.schm_code=g.schm_code and acct_ownership<>'O' and g.bank_id='CI' and g1.bank_id='CI'\r\n"+
                "and acct_cls_date is  null and g.del_flg = 'N' and foracid in (";
        int index=0;
        for(var account : accountId){
            System.out.println("the account is "+account);
            if(index==accountId.size()-1){
                req+="'"+account+"')";
                break;
            }
            req+="'"+account+"',";
            index++;
        }
        System.out.println("the sql request is "+req);
        return req;
    }
}
