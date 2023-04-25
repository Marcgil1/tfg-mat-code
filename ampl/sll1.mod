param numclients;
param numitems;
param numprices;

set CLIENTS       := 1..numclients;
set ITEMS         := 1..numitems;
set PRICE_INDICES := 1..numprices;
set PREFERED {CLIENTS}       within ITEMS;
set KWORSE   {CLIENTS,ITEMS} within ITEMS;

param prices  {PRICE_INDICES};
param budgets {CLIENTS};
param capacities {ITEMS};

var z {CLIENTS}             integer;
var x {CLIENTS,ITEMS}       binary;
var v {PRICE_INDICES,ITEMS} binary;

maximize Gains:
    sum {k in CLIENTS} z[k];

s.t. At_Most_One_Product_For_Each_Client {k in CLIENTS}:
    sum {i in PREFERED[k]}   x[k,i] <= 1;

s.t. At_Most_One_Price_For_Each_Product {i in ITEMS}:
    sum {l in PRICE_INDICES} v[l,i] <= 1;

s.t. Only_Buy_The_Most_Prefered_Products
    {
        k in CLIENTS,
        i in PREFERED[k] : card(KWORSE[k, i]) > 0# TODO: codificar \neq \varempty
    }:
            sum {j in  KWORSE[k, i]} x[k,j]
        +
            sum {l in 1..budgets[k]} v[l,i]
        <=
            1
    ;

s.t. Do_Not_Buy_Over_Budget
    {
        k in CLIENTS,
        i in PREFERED[k]
    }:
            x[k,i]
        +
            sum {l in (budgets[k]+1)..numprices}
                v[l,i]
        <=
            1
    ;

s.t. Benefit_Definition
    {
        k in CLIENTS,
        i in PREFERED[k]
    }:
            z[k]
        <=
                sum {l in 1..budgets[k]} prices[l] * v[l,i]
            +
                prices[numprices] *
                    sum {
                        j in PREFERED[k] : j <> i
                    } x[k,j]
    ;

s.t. Zero_Benefit_If_No_Product_Acquired
    {
        k in CLIENTS
    }:
            z[k]
        <=
            prices[budgets[k]] *
                sum {i in PREFERED[k]} x[k,i]
    ;
