<template>
  <!-- 调整余额对话框 -->
  <el-dialog :visible.sync="balanceDialogVisible" title="调整用户余额" width="520px" :destroy-on-close="true" :close-on-click-modal="false"
    class="balance-adjust-dialog" @close="handleDialogClose">

    <div class="balance-dialog-content">
      <!-- 用户信息卡片 -->
      <el-card shadow="never" class="user-info-card">
        <div class="user-info">
          <circle-avatar :text="form.realname" size="40" class="user-avatar" />
          <div class="user-details">
            <div class="user-name">{{ form.realname || '用户' }}</div>
            <div class="user-id">ID: {{ form.id }}</div>
          </div>
          <div class="current-balance">
            <div class="balance-label">当前余额</div>
            <div class="balance-value">¥ {{ formatCurrency(data.amount) }}</div>
          </div>
        </div>
      </el-card>

      <!-- 调整表单 -->
      <el-form ref="balanceForm" :model="balanceForm" :rules="balanceRules" label-width="90px" class="balance-form">
        <!-- 调整类型 -->
        <el-form-item label="调整类型:" prop="changeType">
          <el-radio-group v-model="balanceForm.changeType" class="type-radio-group" @change="handleTypeChange">
            <el-radio-button :label="1" class="type-radio recharge-radio">
              <i class="el-icon-circle-plus-outline"></i>
              <span>充值</span>
            </el-radio-button>
            <el-radio-button :label="2" class="type-radio consume-radio">
              <i class="el-icon-circle-minus"></i>
              <span>消费</span>
            </el-radio-button>
            <el-radio-button :label="3" class="type-radio adjust-radio">
              <i class="el-icon-edit"></i>
              <span>手动调整</span>
            </el-radio-button>
          </el-radio-group>
        </el-form-item>

        <!-- 调整金额 -->
        <el-form-item label="调整金额:" prop="changeAmount" class="amount-form-item">
          <div class="amount-input-wrapper">
            <div class="currency-symbol">¥</div>
            <el-input
              v-model.number="balanceForm.changeAmount"
              placeholder="请输入调整金额"
              type="number"
              :min="0.01"
              :step="0.01"
              @input="handleAmountInput"
              class="amount-input"
              ref="amountInput">
              <template slot="append">
                <span class="amount-unit">元</span>
              </template>
            </el-input>
          </div>

          <!-- 快速金额按钮 -->
          <div class="quick-amount-section">
            <div class="quick-amount-title">
              <i class="el-icon-thumb"></i>
              <span>快速金额</span>
            </div>
            <div class="quick-amount-buttons">
              <template v-for="amount in quickAmounts[balanceForm.changeType]">
                <el-button
                  :key="amount"
                  size="mini"
                  :type="balanceForm.changeAmount == getAbsoluteAmount(amount) ? 'primary' : 'default'"
                  :class="['quick-amount-btn', { 'active': balanceForm.changeAmount == getAbsoluteAmount(amount) }]"
                  @click="setQuickAmount(amount)">
                  {{ amount > 0 ? '+' : '' }}{{ formatQuickAmount(Math.abs(amount)) }}
                </el-button>
              </template>
            </div>

            <!-- 自定义金额 -->
            <div class="custom-amount">
              <el-input-number
                v-model="customAmount"
                :min="0.01"
                :max="10000"
                :step="100"
                :precision="2"
                size="small"
                placeholder="自定义"
                class="custom-input"
                @change="setCustomAmount">
                <template slot="append">元</template>
              </el-input-number>
            </div>
          </div>

          <!-- 预览调整效果 -->
          <div v-if="balanceForm.changeAmount" class="amount-preview">
            <div class="preview-item">
              <span class="preview-label">调整后余额:</span>
              <span class="preview-value" :class="getPreviewBalanceClass()">
                ¥ {{ formatCurrency(calculateNewBalance()) }}
              </span>
            </div>
            <div v-if="Math.abs(balanceForm.changeAmount) >= 1000" class="preview-tips">
              <i class="el-icon-warning"></i>
              <span>调整金额较大，请确认操作</span>
            </div>
          </div>
        </el-form-item>

        <!-- 备注信息 -->
        <el-form-item label="备注说明:" prop="remark">
          <el-input
            v-model="balanceForm.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入调整原因或备注信息"
            maxlength="200"
            show-word-limit
            resize="none"
            class="remark-textarea">
          </el-input>

          <!-- 常用备注 -->
          <div class="quick-remark">
            <div class="quick-remark-title">常用备注：</div>
            <div class="quick-remark-buttons">
              <el-tag
                v-for="remark in quickRemarks[balanceForm.changeType]"
                :key="remark"
                size="small"
                :class="{ 'active': balanceForm.remark === remark }"
                @click="setQuickRemark(remark)"
                class="remark-tag">
                {{ remark }}
              </el-tag>
            </div>
          </div>
        </el-form-item>
      </el-form>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <el-button @click="handleCancel" size="medium" class="cancel-btn">
          取消
        </el-button>
        <el-button
          type="primary"
          :loading="balanceSubmitLoading"
          @click="submitBalanceChange"
          size="medium"
          class="submit-btn"
          :disabled="!balanceForm.changeAmount || balanceForm.changeAmount <= 0">
          <i class="el-icon-check"></i>
          {{ getSubmitButtonText() }}
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script>
import CircleAvatar from '@/components/CircleAvatar.vue';

export default {
  name: 'BalanceAdjustDialog',
  components: { CircleAvatar },
  props: {
    visible: Boolean,
    data: Object,
  },
  data() {
    return {
      balanceDialogVisible: this.visible,
      form: {},

      // 余额相关数据
      balanceSubmitLoading: false,
      balanceForm: {
        userId: null,
        changeType: 1,
        changeAmount: null,
        remark: ''
      },

      // 快速金额配置
      quickAmounts: {
        1: [10, 50, 100, 200, 500, 1000],  // 充值
        2: [-10, -50, -100, -200, -500],   // 消费
        3: [100, -100, 500, -500, 1000, -1000] // 手动调整
      },

      // 常用备注
      quickRemarks: {
        1: ['用户主动充值', '活动奖励', '客服补发', '系统赠送'],
        2: ['购买商品', '服务消费', '会员续费', '手续费'],
        3: ['系统调整', '数据修正', '补偿调整', '错误修复']
      },

      // 自定义金额
      customAmount: null
    };
  },
  watch: {
    visible(val) {
      this.balanceDialogVisible = val;
      if (val) {
        this.initDialog();
      }
    },
    data: {
      immediate: true,
      handler(val) {
        if (val) {
          this.form = { ...val };
          this.balanceForm.userId = val.id;
        } else {
          this.form = {};
          this.balanceForm.userId = null;
        }
      }
    }
  },
  computed: {
    balanceRules() {
      return {
        changeType: [
          { required: true, message: '请选择调整类型', trigger: 'change' }
        ],
        changeAmount: [
          { required: true, message: '请输入调整金额', trigger: 'blur' },
          {
            type: 'number',
            message: '金额必须为数字',
            trigger: 'blur'
          },
          {
            validator: (rule, value, callback) => {
              if (value <= 0) {
                callback(new Error('调整金额必须大于0'));
                return;
              }

              // 如果是消费类型，且调整后的余额会变成负数，给出警告
              if (this.balanceForm.changeType === 2 && this.data.amount - value < 0) {
                callback(new Error('消费金额不能大于当前余额'));
                return;
              }

              callback();
            },
            trigger: 'blur'
          }
        ]
      };
    }
  },
  methods: {
    /* 初始化对话框 */
    initDialog() {
      this.balanceForm = {
        userId: this.form.id,
        changeType: 1,
        changeAmount: null,
        remark: ''
      };
      this.customAmount = null;

      // 自动聚焦金额输入框
      this.$nextTick(() => {
        if (this.$refs.amountInput) {
          this.$refs.amountInput.focus();
        }
        if (this.$refs.balanceForm) {
          this.$refs.balanceForm.clearValidate();
        }
      });
    },

    /* 处理对话框关闭 */
    handleDialogClose() {
      this.updateVisible(false);
    },

    /* 处理取消 */
    handleCancel() {
      this.updateVisible(false);
    },

    /* 更新visible */
    updateVisible(value) {
      this.$emit('update:visible', value);
      if (!value) {
        this.resetForm();
      }
    },

    /* 重置表单 */
    resetForm() {
      if (this.$refs.balanceForm) {
        this.$refs.balanceForm.resetFields();
      }
      this.balanceSubmitLoading = false;
      this.customAmount = null;
    },

    /* 处理调整类型变化 */
    handleTypeChange() {
      // 切换类型时重置金额
      this.balanceForm.changeAmount = null;
      this.customAmount = null;

      // 清除金额验证
      if (this.$refs.balanceForm) {
        this.$refs.balanceForm.clearValidate('changeAmount');
      }
    },

    /* 获取绝对金额 */
    getAbsoluteAmount(amount) {
      return Math.abs(amount);
    },

    /* 设置快速金额 */
    setQuickAmount(amount) {
      const absAmount = Math.abs(amount);

      // 如果是消费类型，使用负数金额
      if (this.balanceForm.changeType === 2) {
        this.balanceForm.changeAmount = -absAmount;
      } else {
        this.balanceForm.changeAmount = absAmount;
      }

      // 同时更新自定义金额显示
      this.customAmount = absAmount;

      // 触发验证
      this.$nextTick(() => {
        if (this.$refs.balanceForm) {
          this.$refs.balanceForm.validateField('changeAmount');
        }
      });
    },

    /* 设置自定义金额 */
    setCustomAmount(value) {
      if (value && value > 0) {
        // 如果是消费类型，使用负数金额
        if (this.balanceForm.changeType === 2) {
          this.balanceForm.changeAmount = -value;
        } else {
          this.balanceForm.changeAmount = value;
        }

        // 触发验证
        this.$nextTick(() => {
          if (this.$refs.balanceForm) {
            this.$refs.balanceForm.validateField('changeAmount');
          }
        });
      }
    },

    /* 设置快速备注 */
    setQuickRemark(remark) {
      this.balanceForm.remark = remark;
    },

    /* 格式化快速金额显示 */
    formatQuickAmount(amount) {
      if (amount >= 1000) {
        return (amount / 1000).toFixed(1) + 'K';
      }
      return amount.toString();
    },

    /* 金额输入处理 */
    handleAmountInput(value) {
      // 确保输入的是数字
      if (value === '' || value === null || value === undefined) {
        this.balanceForm.changeAmount = null;
        return;
      }

      let numValue = Number(value);

      // 检查是否为有效数字
      if (isNaN(numValue)) {
        this.balanceForm.changeAmount = null;
        return;
      }

      // 限制最多两位小数
      numValue = Math.round(numValue * 100) / 100;

      // 限制最小值为0.01
      if (numValue <= 0) {
        numValue = 0.01;
      }

      // 根据类型处理正负号
      if (this.balanceForm.changeType === 2) {
        // 消费类型确保为负数
        this.balanceForm.changeAmount = -Math.abs(numValue);
      } else {
        // 充值和调整类型确保为正数
        this.balanceForm.changeAmount = Math.abs(numValue);
      }

      // 更新自定义金额显示
      this.customAmount = Math.abs(numValue);
    },

    /* 计算新余额 */
    calculateNewBalance() {
      if (!this.balanceForm.changeAmount) return this.data.amount;

      const changeAmount = Number(this.balanceForm.changeAmount);
      return this.data.amount + changeAmount;
    },

    /* 获取预览余额的样式类 */
    getPreviewBalanceClass() {
      const newBalance = this.calculateNewBalance();
      if (newBalance < 0) {
        return 'balance-negative';
      } else if (newBalance > this.data.amount) {
        return 'balance-positive';
      } else if (newBalance < this.data.amount) {
        return 'balance-decrease';
      }
      return '';
    },

    /* 获取提交按钮文本 */
    getSubmitButtonText() {
      if (this.balanceSubmitLoading) {
        return '处理中...';
      }

      const amount = this.balanceForm.changeAmount;
      if (!amount || amount <= 0) return '确认调整';

      const absAmount = Math.abs(amount);
      const typeText = {
        1: '充值',
        2: '消费',
        3: '调整'
      }[this.balanceForm.changeType] || '调整';

      return `确认${typeText} ¥${this.formatCurrency(absAmount)}`;
    },

    /* 提交余额调整 */
    async submitBalanceChange() {
      try {
        const valid = await this.$refs.balanceForm.validate();
        if (!valid) return;

        // 确认提示
        const amount = Math.abs(this.balanceForm.changeAmount);
        const typeText = {
          1: '充值',
          2: '消费',
          3: '手动调整'
        }[this.balanceForm.changeType];

        const newBalance = this.calculateNewBalance();
        const confirmMessage = `
          <div class="confirm-message">
            <p>确定要执行以下操作吗？</p>
            <p class="confirm-detail">
              <strong>操作类型：</strong>${typeText}<br>
              <strong>操作金额：</strong>¥ ${this.formatCurrency(amount)}<br>
              <strong>当前余额：</strong>¥ ${this.formatCurrency(this.data.amount)}<br>
              <strong>调整后余额：</strong>¥ ${this.formatCurrency(newBalance)}
            </p>
            ${newBalance < 0 ? '<p class="confirm-warning"><i class="el-icon-warning"></i> 注意：调整后余额将变为负数！</p>' : ''}
            ${Math.abs(amount) >= 1000 ? '<p class="confirm-warning"><i class="el-icon-warning"></i> 此操作涉及较大金额，请谨慎确认！</p>' : ''}
          </div>
        `;

        await this.$confirm(confirmMessage, '确认调整余额', {
          confirmButtonText: '确认调整',
          cancelButtonText: '再想想',
          type: newBalance < 0 ? 'error' : 'warning',
          dangerouslyUseHTMLString: true,
          customClass: 'balance-confirm-dialog',
          showClose: false
        });

        this.balanceSubmitLoading = true;

        // 准备提交数据
        const submitData = {
          id: this.balanceForm.userId,
          type: this.balanceForm.changeType,
          amount: Number(this.balanceForm.changeAmount),
          description: this.balanceForm.remark || `${typeText}调整`
        };

        const response = await this.$http.post('/asset/balance/adjust', submitData);

        if (response.data.code === 200) {
          this.$message.success({
            message: response.data.message || '余额调整成功',
            type: 'success',
            duration: 2000
          });

          this.updateVisible(false);

          // 触发成功回调
          this.$emit('success', {
            newBalance: response.data.data?.newBalance || newBalance,
            changeAmount: this.balanceForm.changeAmount,
            changeType: this.balanceForm.changeType
          });

        } else {
          this.$message.error(response.data.message || '余额调整失败');
        }
      } catch (error) {
        // 用户取消操作
        if (error !== 'cancel' && error !== 'close') {
          console.error('余额调整失败:', error);
          this.$message.error('余额调整失败：' + (error.message || '网络错误'));
        }
      } finally {
        this.balanceSubmitLoading = false;
      }
    },

    /* 格式化金额 */
    formatCurrency(amount) {
      if (amount === null || amount === undefined) return '0.00';

      // 处理字符串数字
      const num = Number(amount);
      if (isNaN(num)) return '0.00';

      // 保留两位小数
      const formatted = num.toFixed(2);

      // 添加千位分隔符
      return formatted.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }
  }
};
</script>

<style scoped>
/* 对话框样式 */
.balance-adjust-dialog :deep(.el-dialog) {
  border-radius: 12px;
  overflow: hidden;
}

.balance-adjust-dialog :deep(.el-dialog__header) {
  background: linear-gradient(135deg, #409eff 0%, #337ecc 100%);
  padding: 16px 20px;
}

.balance-adjust-dialog :deep(.el-dialog__title) {
  color: white;
  font-size: 16px;
  font-weight: 600;
}

.balance-adjust-dialog :deep(.el-dialog__headerbtn .el-dialog__close) {
  color: white;
}

.balance-adjust-dialog :deep(.el-dialog__body) {
  padding: 0;
}

.balance-dialog-content {
  padding: 20px;
}

/* 用户信息卡片 */
.user-info-card {
  margin-bottom: 20px;
  border: 1px solid #e6ebf5;
  border-radius: 8px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.user-avatar {
  flex-shrink: 0;
}

.user-details {
  flex: 1;
}

.user-name {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}

.user-id {
  font-size: 12px;
  color: #909399;
  background: #f5f7fa;
  padding: 2px 8px;
  border-radius: 10px;
  display: inline-block;
}

.current-balance {
  text-align: right;
  flex-shrink: 0;
}

.balance-label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
}

.balance-value {
  font-size: 20px;
  font-weight: 700;
  color: #67c23a;
}

/* 调整类型按钮组 */
.type-radio-group {
  display: flex;
  gap: 8px;
  width: 100%;
}

.type-radio {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.type-radio i {
  font-size: 16px;
}

.type-radio span {
  font-weight: 500;
}

.recharge-radio :deep(.el-radio-button__inner) {
  border-color: #67c23a;
  color: #67c23a;
}

.recharge-radio :deep(.el-radio-button__orig-radio:checked + .el-radio-button__inner) {
  background: linear-gradient(135deg, #67c23a 0%, #5daf34 100%);
  border-color: #67c23a;
}

.consume-radio :deep(.el-radio-button__inner) {
  border-color: #f56c6c;
  color: #f56c6c;
}

.consume-radio :deep(.el-radio-button__orig-radio:checked + .el-radio-button__inner) {
  background: linear-gradient(135deg, #f56c6c 0%, #e64242 100%);
  border-color: #f56c6c;
}

.adjust-radio :deep(.el-radio-button__inner) {
  border-color: #409eff;
  color: #409eff;
}

.adjust-radio :deep(.el-radio-button__orig-radio:checked + .el-radio-button__inner) {
  background: linear-gradient(135deg, #409eff 0%, #337ecc 100%);
  border-color: #409eff;
}

/* 金额输入区域 */
.amount-form-item {
  margin-bottom: 24px;
}

.amount-input-wrapper {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 16px;
}

.currency-symbol {
  font-size: 24px;
  font-weight: 700;
  color: #409eff;
  width: 40px;
  text-align: center;
}

.amount-input {
  flex: 1;
}

.amount-input :deep(.el-input__inner) {
  font-size: 20px;
  font-weight: 600;
  height: 48px;
  text-align: right;
  border-color: #409eff;
}

.amount-unit {
  color: #606266;
  font-weight: 500;
  padding: 0 12px;
}

/* 快速金额区域 */
.quick-amount-section {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 16px;
  margin-top: 16px;
}

.quick-amount-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 500;
  color: #606266;
  margin-bottom: 12px;
}

.quick-amount-title i {
  color: #409eff;
}

.quick-amount-buttons {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-bottom: 12px;
}

.quick-amount-btn {
  height: 36px;
  border-radius: 6px;
  font-weight: 500;
  transition: all 0.2s ease;
}

.quick-amount-btn.active {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.2);
}

/* 自定义金额 */
.custom-amount {
  margin-top: 12px;
}

.custom-input {
  width: 150px;
}

.custom-input :deep(.el-input-number__increase),
.custom-input :deep(.el-input-number__decrease) {
  background: #f5f7fa;
}

/* 金额预览 */
.amount-preview {
  background: #f0f9ff;
  border-radius: 8px;
  padding: 12px 16px;
  margin-top: 16px;
  border: 1px solid #d9ecff;
}

.preview-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.preview-label {
  color: #606266;
  font-size: 14px;
}

.preview-value {
  font-size: 18px;
  font-weight: 700;
}

.preview-value.balance-positive {
  color: #67c23a;
}

.preview-value.balance-decrease {
  color: #e6a23c;
}

.preview-value.balance-negative {
  color: #f56c6c;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% {
    opacity: 1;
  }

  50% {
    opacity: 0.7;
  }

  100% {
    opacity: 1;
  }
}

.preview-tips {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #e6a23c;
  font-size: 12px;
  padding-top: 8px;
  border-top: 1px dashed #f0c48a;
}

.preview-tips i {
  font-size: 14px;
}

/* 备注区域 */
.remark-textarea {
  margin-bottom: 12px;
}

.quick-remark {
  margin-top: 12px;
}

.quick-remark-title {
  font-size: 12px;
  color: #909399;
  margin-bottom: 8px;
}

.quick-remark-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.remark-tag {
  cursor: pointer;
  transition: all 0.2s ease;
}

.remark-tag:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.remark-tag.active {
  background: #409eff;
  color: white;
  border-color: #409eff;
}

/* 底部按钮 */
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px 20px;
  border-top: 1px solid #e6ebf5;
}

.cancel-btn {
  min-width: 80px;
}

.submit-btn {
  min-width: 140px;
  background: linear-gradient(135deg, #67c23a 0%, #5daf34 100%);
  border: none;
  font-weight: 500;
}

.submit-btn:hover {
  background: linear-gradient(135deg, #85ce61 0%, #67c23a 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(103, 194, 58, 0.3);
}

.submit-btn:active {
  transform: translateY(0);
}

.submit-btn:disabled {
  background: #c0c4cc;
  transform: none;
  box-shadow: none;
  cursor: not-allowed;
}

/* 响应式调整 */
@media (max-width: 600px) {
  .user-info {
    flex-direction: column;
    text-align: center;
  }

  .current-balance {
    text-align: center;
  }

  .quick-amount-buttons {
    grid-template-columns: repeat(2, 1fr);
  }

  .type-radio-group {
    flex-direction: column;
  }
}
</style>

<style>
/* 全局样式 */
.balance-confirm-dialog .el-message-box__message p {
  margin: 8px 0;
}

.balance-confirm-dialog .confirm-detail {
  background: #f8f9fa;
  padding: 12px;
  border-radius: 6px;
  margin: 12px 0;
  line-height: 1.6;
}

.balance-confirm-dialog .confirm-warning {
  color: #e6a23c;
  font-weight: 500;
  padding: 8px;
  background: #fdf6ec;
  border-radius: 4px;
  margin-top: 12px;
}

.balance-confirm-dialog .confirm-warning i {
  margin-right: 6px;
}
</style>
