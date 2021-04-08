package com.zoundz.activity;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.RadioButton;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;

import com.android.billingclient.api.AcknowledgePurchaseParams;
import com.android.billingclient.api.AcknowledgePurchaseResponseListener;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.ConsumeParams;
import com.android.billingclient.api.ConsumeResponseListener;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.android.billingclient.api.SkuDetails;
import com.android.billingclient.api.SkuDetailsParams;
import com.android.billingclient.api.SkuDetailsResponseListener;
import com.zoundz.R;
import com.zoundz.application.AppController;
import com.zoundz.bean.SubscriptionBean;
import com.zoundz.bean.UserBean;
import com.zoundz.databinding.ActivityPromocodeBinding;
import com.zoundz.pref.UserPref;
import com.zoundz.receiver.ConnectivityReceiver;
import com.zoundz.util.CustomCrouton;
import com.zoundz.util.HeaderConfig;
import com.zoundz.viewmodel.PetViewModel;
import com.zoundz.viewmodel.PromoCodeViewModel;
import com.zoundz.viewmodel.SubscriptionViewModel;

import java.util.ArrayList;
import java.util.List;
/*
 * Copyright Subcodevs, Inc. 2021
 */
public class PromocodeActivity extends AppCompatActivity implements ConnectivityReceiver.ConnectivityReceiverListener, View.OnClickListener{

    private ActivityPromocodeBinding binding;

    private SkuDetails skuDetails;
    private BillingClient billingClient;

    private List<SkuDetails> skuDetailList;

    int selectedSubscription =  0;

    private SubscriptionViewModel viewModel;
    private SubscriptionBean subscriptionBean;
    private UserBean userBean;

    private PromoCodeViewModel promoCodeViewModel;

    private Animation animationUp;
    private Animation animationDown;


    private PurchasesUpdatedListener purchaseUpdateListener = new PurchasesUpdatedListener() {
        @Override
        public void onPurchasesUpdated(BillingResult billingResult, List<Purchase> purchases) {
            // To be implemented in a later section.

            if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK
                    && purchases != null) {
                for (Purchase purchase : purchases) {
                    Log.e("Purchase",purchase.getOriginalJson());

                    viewModel.validate(userBean.getUserID(), purchase.getSku(), purchase.getPurchaseToken() );
                    handlePurchase(purchase);
                }
            } else if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.USER_CANCELED) {
                // Handle an error caused by a user cancelling the purchase flow.
                new CustomCrouton(PromocodeActivity.this, getString(R.string.subscription_canceled), binding.errorCheckLayout.errorCheckLayout).setInAnimation();

            } else {
                Log.e("Purchase Error",billingResult.getResponseCode()+"");
            }
        }

    };


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityPromocodeBinding.inflate(getLayoutInflater());
        View view = binding.getRoot();
        setContentView(view);

        viewModel = ViewModelProviders.of(this).get(SubscriptionViewModel.class);
        promoCodeViewModel = ViewModelProviders.of(this).get(PromoCodeViewModel.class);

        animationUp = AnimationUtils.loadAnimation(getApplicationContext(), R.anim.slide_up_anim);
        animationDown = AnimationUtils.loadAnimation(getApplicationContext(), R.anim.slide_down_anim);


        userBean = UserPref.getUser();

        setupBillingClient();

        binding.btnVerifyCode.setOnClickListener(this);
        binding.subscribeButton.setOnClickListener(this);

        binding.rlMonth.setOnClickListener(this);
        binding.rlYear.setOnClickListener(this);
        binding.radioMonthly.setOnClickListener(this);
        binding.radioYearly.setOnClickListener(this);

        binding.collapseExpandeOne.setOnClickListener(this);
        binding.collapseExpandeSecond.setOnClickListener(this);
        binding.collapseExpandeOne.setRotationX(180);
        binding.collapseExpandeSecond.setRotationX(180);


        observeUpdatedMesssage();
        obserbPromoSuccess();
        observeSuccessLogin();
        observeValidation();

        observeLoader();


        // Use TextWatcher to change button state by EditText text length.
        binding.editPromocode.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }
             @Override
            public void afterTextChanged(Editable editable) {
                enableDisableVeifyButton();
            }
        });

        binding.editPromocode.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View view, int i, KeyEvent keyEvent) {

                // Get key action, up or down.
                int action = keyEvent.getAction();
                 if(action == KeyEvent.ACTION_UP) {
                    enableDisableVeifyButton();
                }
                return false;
            }
        });

    }


    private void  enableDisableVeifyButton(){
        if (binding.editPromocode.getText().toString().trim().length() >= 10) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                binding.btnVerifyCode.setBackground(getDrawable(R.drawable.btn_enable_shape));
                binding.btnVerifyCode.setEnabled(true);
            }
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                binding.btnVerifyCode.setBackground(getDrawable(R.drawable.btn_disable_shape));
                binding.btnVerifyCode.setEnabled(false);
            }
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {

            case R.id.back:
                finish();
                break;
            case R.id.btnVerifyCode:


                verifyPromoCode();


                break;

            case R.id.subscribeButton: {

                if (skuDetailList != null && skuDetailList.size() > 0){

                    if(skuDetailList.size()>0) {
                        skuDetails = skuDetailList.get(selectedSubscription);
                    }

                    BillingFlowParams billingFlowParams = BillingFlowParams.newBuilder()
                            .setSkuDetails(skuDetails)
                            .build();
                     int responseCode = billingClient.launchBillingFlow(this, billingFlowParams).getResponseCode();
             }
            }
                break;
            case R.id.radioMonthly:
            case R.id.rlMonth:{
               binding.radioYearly.setChecked(false);
               binding.radioMonthly.setChecked(true);
                selectedSubscription = 0;
            }break;
            case R.id.radioYearly:
            case R.id.rlYear :{
                binding.radioYearly.setChecked(true);
                binding.radioMonthly.setChecked(false);
                selectedSubscription = 1;
            }break;


            case R.id.collapseExpandeOne: {
                binding.tvSecondNote.setVisibility(View.GONE);
                if(binding.tvFirstNote.isShown()){
                    binding.tvFirstNote.setVisibility(View.GONE);
                    binding.collapseExpandeOne.setRotationX(180);
                   // binding.tvFirstNote.startAnimation(animationUp);
                } else{
                    binding.tvFirstNote.setVisibility(View.VISIBLE);
                   // binding.tvFirstNote.startAnimation(animationDown);
                    binding.collapseExpandeOne.setRotationX(0);
                }
            }break;

            case R.id.collapseExpandeSecond: {
                binding.tvFirstNote.setVisibility(View.GONE);
                if(binding.tvSecondNote.isShown()){
                    binding.tvSecondNote.setVisibility(View.GONE);
                    binding.collapseExpandeSecond.setRotationX(180);
                    //binding.tvSecondNote.startAnimation(animationUp);
                } else{
                    binding.tvSecondNote.setVisibility(View.VISIBLE);
                    //binding.tvSecondNote.startAnimation(animationDown);
                    binding.collapseExpandeSecond.setRotationX(0);
                }
            }break;


        }

    }

    private void verifyPromoCode() {
        promoCodeViewModel.applyPrmoCode( userBean.getUserID(), binding.editPromocode.getText().toString());
    }

    private void observeUpdatedMesssage() {
        viewModel.getUpdateMsg().observe(this,msg->{
            AppController.getInstance().getDefaultDialog().showActivityFinishError(PromocodeActivity.this, msg);
        });
    }


    private  void obserbPromoSuccess(){
        promoCodeViewModel.getUpdateMsg().observe(this,msg->{
            AppController.getInstance().getDefaultDialog().showActivityFinishError(PromocodeActivity.this, msg);
        });
    }

    private void observeLoader() {
        promoCodeViewModel.getLoader().observe(this, new Observer<Boolean>() {
            @Override
            public void onChanged(@Nullable Boolean loader) {
                if(loader){
                    AppController.getInstance().getDefaultLoader().showProgress(PromocodeActivity.this);
                }else{
                    AppController.getInstance().getDefaultLoader().dismiss();
                }
            }
        });
    }




    @Override
    protected void onResume() {
        super.onResume();


        HeaderConfig.getInstance().configureHeader(binding.header, this,
                "Subscription");
        AppController.getInstance().setConnectivityListener(this);

    }

    @Override
    public void onNetworkConnectionChanged(boolean isConnected) {
        if (!isConnected) {
            new CustomCrouton(this, getString(R.string.no_connection), binding.errorCheckLayout.errorCheckLayout).setInAnimation();
        }
    }



    private void setupBillingClient() {

        billingClient = BillingClient.newBuilder(this)
                .setListener(purchaseUpdateListener)
                .enablePendingPurchases()
                .build();


        billingClient.startConnection(new BillingClientStateListener() {
            @Override
            public void onBillingSetupFinished(BillingResult billingResult) {
                if (billingResult.getResponseCode() ==  BillingClient.BillingResponseCode.OK) {
                    // The BillingClient is ready. You can query purchases here.

                    loadAllSKUs();
                }
            }
            @Override
            public void onBillingServiceDisconnected() {
                // Try to restart the connection on the next request to
                // Google Play by calling the startConnection() method.
                Log.d("BILLING SERVICE:", "DISCONNECTED");
            }
        });

    }

    private void loadAllSKUs() {
        List<String> skuList = new ArrayList<>();
        skuList.add("com.zoundz.monthly");
        skuList.add("com.zoundz.yearly");
        SkuDetailsParams.Builder params = SkuDetailsParams.newBuilder();
        params.setSkusList(skuList).setType(BillingClient.SkuType.SUBS);

        billingClient.querySkuDetailsAsync(params.build(),
                new SkuDetailsResponseListener() {
                    @Override
                    public void onSkuDetailsResponse(BillingResult billingResult,
                                                     List<SkuDetails> skuDetailsList) {


                        skuDetailList = skuDetailsList;
                        if(skuDetailsList.size() > 1) {
                            skuDetails = skuDetailsList.get(selectedSubscription);

                         //   binding.tvMonthTitle.setText(skuDetailsList.get(0).getDescription());
                          //  binding.tvYearTitle.setText(skuDetailsList.get(1).getDescription());

                            binding.monthlySubsPrice.setText(skuDetailsList.get(0).getPrice());
                            binding.yearlySubsPrice.setText(skuDetailsList.get(1).getPrice());

                            long yearMonthlyPrice = skuDetailsList.get(1).getOriginalPriceAmountMicros();
                            Double ytoMPrice = Double.valueOf((yearMonthlyPrice /1000000));
                            binding.tvYearMonthly.setText("/annually ("+( String.format("%.2f", ytoMPrice/12)) +"/month)");
                        }
                    }
                });

    }


    void handlePurchase(Purchase purchase) {

        if (purchase.getPurchaseState() == Purchase.PurchaseState.PURCHASED) {
            if (!purchase.isAcknowledged()) {
                AcknowledgePurchaseParams acknowledgePurchaseParams =
                        AcknowledgePurchaseParams.newBuilder()
                                .setPurchaseToken(purchase.getPurchaseToken())
                                .build();
                billingClient.acknowledgePurchase(acknowledgePurchaseParams, new AcknowledgePurchaseResponseListener(){

                    @Override
                    public void onAcknowledgePurchaseResponse(@NonNull BillingResult billingResult) {

                        if(billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK){
                            new CustomCrouton(PromocodeActivity.this, "Purchase Acknowledged", binding.errorCheckLayout.errorCheckLayout).setInAnimation();
                        }
                    }
                });
            }
        }

        ConsumeParams consumeParams =
                ConsumeParams.newBuilder()
                        .setPurchaseToken(purchase.getPurchaseToken())
                        .build();

        ConsumeResponseListener listener = new ConsumeResponseListener() {
            @Override
            public void onConsumeResponse(BillingResult billingResult, String purchaseToken) {
                if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                    // Handle the success of the consume operation

                    Log.e("Billing result", billingResult.getDebugMessage());
                    Log.e("Billing purchaseToken", purchaseToken);
                }
            }
        };

        billingClient.consumeAsync(consumeParams, listener);
    }



    private void observeValidation() {
        viewModel.getErrorMsg().observe(this, new Observer<String>() {
            @Override
            public void onChanged(@Nullable String s) {
                AppController.getInstance().getDefaultDialog().showError(PromocodeActivity.this,s);
            }
        });
    }

    private void observeSuccessLogin() {
        viewModel.getSubscriptionLiveData().observe(this, new Observer<SubscriptionBean>() {
            @Override
            public void onChanged(SubscriptionBean subscriptionBean) {
                subscriptionBean = subscriptionBean;
                Intent intent = new Intent(PromocodeActivity.this, SubscriptionListActivity.class);
                startActivity(intent);
            }
        });


    }

}
