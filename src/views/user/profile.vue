<template>
  <div class="ele-body">
    <el-row :gutter="15">
      <!-- 左侧用户信息卡片 -->
      <el-col :md="6" :sm="8">
        <el-card shadow="never" body-style="padding: 25px;">
          <div class="user-info-card">
            <div class="user-info-avatar">
              <circle-avatar :text="form.realname" size="96" />
            </div>
            <h2 class="user-info-name">{{ form.realname }}</h2>
            <div class="user-info-desc">
              {{ form.intro || '这个人很懒，什么都没有写~' }}
            </div>
          </div>

          <!-- 余额卡片 -->
          <div class="balance-card">
            <div class="balance-title">
              <i class="el-icon-wallet"></i>
              <span>账户余额</span>
            </div>
            <div class="balance-amount">
              ¥ <span class="balance-number">{{ formatCurrency(balance) }}</span>
            </div>
            <div class="balance-actions">
              <el-button
                type="primary"
                size="small"
                icon="el-icon-plus"
                @click="showRechargeDialog"
              >
                充值
              </el-button>
              <el-button
                type="success"
                size="small"
                icon="el-icon-shopping-cart-full"
                @click="showConsumeDialog"
              >
                消费
              </el-button>
            </div>
          </div>

          <div style="margin: 30px 0 20px 0;">
            <el-divider class="ele-divider-dashed ele-divider-base" />
          </div>

          <!-- 用户基本信息 -->
          <div class="user-info-list">
            <div class="user-info-item">
              <i class="el-icon-user"></i>
              <span>{{ form.username }}</span>
            </div>
            <div class="user-info-item">
              <i class="el-icon-phone-outline"></i>
              <span>{{ form.mobile || '未填写' }}</span>
            </div>
            <div class="user-info-item">
              <i class="el-icon-message"></i>
              <span>{{ form.email || '未填写' }}</span>
            </div>
            <div class="user-info-item">
              <i class="el-icon-location-information"></i>
              <span>{{ form.address || '未填写' }}</span>
            </div>
            <div class="user-info-item">
              <i class="el-icon-date"></i>
              <span>注册时间: {{ formatDate(form.createTime) }}</span>
            </div>
            <div class="user-info-item">
              <i class="el-icon-collection-tag"></i>
              <span>用户等级: {{ getUserLevelText(form.level) }}</span>
            </div>
          </div>

          <!-- 统计卡片 -->
          <div class="statistics-card">
            <div class="statistics-item">
              <div class="statistics-label">消费总额</div>
              <div class="statistics-value">¥ {{ formatCurrency(totalConsume) }}</div>
            </div>
            <div class="statistics-item">
              <div class="statistics-label">充值总额</div>
              <div class="statistics-value">¥ {{ formatCurrency(totalRecharge) }}</div>
            </div>
            <div class="statistics-item">
              <div class="statistics-label">消费次数</div>
              <div class="statistics-value">{{ consumeCount }} 次</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 右侧内容区域 -->
      <el-col :md="18" :sm="16">
        <el-card shadow="never" body-style="padding-top: 5px;">
          <el-tabs v-model="active" class="user-info-tabs">
            <!-- 基本信息标签页 -->
            <el-tab-pane label="基本信息" name="info">
              <el-form
                ref="infoForm"
                :model="form"
                :rules="rules"
                label-width="90px"
                style="max-width: 450px; padding-top: 40px;"
                @keyup.enter.native="save"
                @submit.native.prevent
              >
                <el-form-item label="姓名:" prop="realname">
                  <el-input v-model="form.realname" placeholder="请输入姓名" clearable />
                </el-form-item>
                <el-form-item label="昵称:" prop="nickname">
                  <el-input v-model="form.nickname" placeholder="请输入昵称" clearable />
                </el-form-item>
                <el-form-item label="性别:" prop="gender">
                  <el-select v-model="form.gender" placeholder="请选择性别" class="ele-fluid" clearable>
                    <el-option label="男" :value="1" />
                    <el-option label="女" :value="2" />
                    <el-option label="保密" :value="3" />
                  </el-select>
                </el-form-item>
                <el-form-item label="联系方式:" prop="mobile">
                  <el-input v-model="form.mobile" placeholder="请输入联系方式" clearable />
                </el-form-item>
                <el-form-item label="邮箱:" prop="email">
                  <el-input v-model="form.email" placeholder="请输入邮箱" clearable />
                </el-form-item>
                <el-form-item label="详细地址:">
                  <el-input v-model="form.address" placeholder="请输入详细地址" clearable />
                </el-form-item>
                <el-form-item label="个人简介:">
                  <el-input v-model="form.intro" placeholder="请输入个人简介" :rows="4" type="textarea" />
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" @click="save" :loading="loading">
                    保存更改
                  </el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>

            <!-- 余额记录标签页 -->
            <el-tab-pane label="余额记录" name="balance">
              <div class="balance-record">
                <!-- 筛选条件 -->
                <div class="filter-bar">
                  <el-form :inline="true" :model="recordQuery" size="small">
                    <el-form-item label="交易类型:">
                      <el-select v-model="recordQuery.type" placeholder="全部类型" clearable>
                        <el-option label="充值" :value="1" />
                        <el-option label="消费" :value="2" />
                        <el-option label="退款" :value="3" />
                        <el-option label="系统赠送" :value="4" />
                        <el-option label="系统扣除" :value="5" />
                      </el-select>
                    </el-form-item>
                    <el-form-item label="时间范围:">
                      <el-date-picker
                        v-model="recordQuery.dateRange"
                        type="daterange"
                        range-separator="至"
                        start-placeholder="开始日期"
                        end-placeholder="结束日期"
                        value-format="yyyy-MM-dd"
                      />
                    </el-form-item>
                    <el-form-item>
                      <el-button type="primary" @click="searchRecords">查询</el-button>
                      <el-button @click="resetSearch">重置</el-button>
                      <el-button type="success" icon="el-icon-download" @click="exportRecords">
                        导出
                      </el-button>
                    </el-form-item>
                  </el-form>
                </div>

                <!-- 统计信息 -->
                <div class="record-statistics">
                  <el-row :gutter="20">
                    <el-col :span="6">
                      <div class="stat-card">
                        <div class="stat-icon income">
                          <i class="el-icon-money"></i>
                        </div>
                        <div class="stat-content">
                          <div class="stat-label">总收入</div>
                          <div class="stat-value">¥ {{ formatCurrency(recordStats.totalIncome) }}</div>
                        </div>
                      </div>
                    </el-col>
                    <el-col :span="6">
                      <div class="stat-card">
                        <div class="stat-icon expense">
                          <i class="el-icon-shopping-cart-full"></i>
                        </div>
                        <div class="stat-content">
                          <div class="stat-label">总支出</div>
                          <div class="stat-value">¥ {{ formatCurrency(recordStats.totalExpense) }}</div>
                        </div>
                      </div>
                    </el-col>
                    <el-col :span="6">
                      <div class="stat-card">
                        <div class="stat-icon recharge">
                          <i class="el-icon-circle-plus-outline"></i>
                        </div>
                        <div class="stat-content">
                          <div class="stat-label">充值次数</div>
                          <div class="stat-value">{{ recordStats.rechargeCount }} 次</div>
                        </div>
                      </div>
                    </el-col>
                    <el-col :span="6">
                      <div class="stat-card">
                        <div class="stat-icon consume">
                          <i class="el-icon-shopping-bag-1"></i>
                        </div>
                        <div class="stat-content">
                          <div class="stat-label">消费次数</div>
                          <div class="stat-value">{{ recordStats.consumeCount }} 次</div>
                        </div>
                      </div>
                    </el-col>
                  </el-row>
                </div>

                <!-- 余额记录表格 -->
                <el-table
                  :data="recordList"
                  style="width: 100%;"
                  :loading="recordLoading"
                  stripe
                  highlight-current-row
                >
                  <el-table-column
                    prop="orderNo"
                    label="订单号"
                    width="200"
                  >
                    <template slot-scope="{ row }">
                      <span class="order-no">{{ row.orderNo }}</span>
                      <el-tag
                        v-if="row.orderNo"
                        size="mini"
                        type="info"
                        style="margin-left: 5px; cursor: pointer;"
                        @click="copyOrderNo(row.orderNo)"
                      >
                        复制
                      </el-tag>
                    </template>
                  </el-table-column>
                  <el-table-column prop="type" label="交易类型" width="120">
                    <template slot-scope="{ row }">
                      <el-tag
                        :type="getRecordTypeTag(row.type)"
                        size="small"
                      >
                        {{ getRecordTypeText(row.type) }}
                      </el-tag>
                    </template>
                  </el-table-column>
                  <el-table-column prop="amount" label="金额" width="120" align="right">
                    <template slot-scope="{ row }">
                      <span :class="row.amount > 0 ? 'income-text' : 'expense-text'">
                        {{ row.amount > 0 ? '+' : '' }}{{ formatCurrency(row.amount) }}
                      </span>
                    </template>
                  </el-table-column>
                  <el-table-column prop="balanceAfter" label="余额" width="120" align="right">
                    <template slot-scope="{ row }">
                      ¥ {{ formatCurrency(row.balanceAfter) }}
                    </template>
                  </el-table-column>
                  <el-table-column prop="description" label="描述">
                    <template slot-scope="{ row }">
                      <div class="record-description">
                        <span>{{ row.description }}</span>
                        <el-tag
                          v-if="row.status === 0"
                          size="mini"
                          type="warning"
                          style="margin-left: 5px;"
                        >
                          待处理
                        </el-tag>
                      </div>
                    </template>
                  </el-table-column>
                  <el-table-column prop="createTime" label="时间" width="180">
                    <template slot-scope="{ row }">
                      {{ formatDateTime(row.createTime) }}
                    </template>
                  </el-table-column>
                  <el-table-column label="操作" width="100" fixed="right">
                    <template slot-scope="{ row }">
                      <el-button
                        v-if="row.orderNo"
                        type="text"
                        size="small"
                        @click="viewOrderDetail(row)"
                      >
                        详情
                      </el-button>
                      <el-button
                        v-if="row.type === 1 && row.status === 0"
                        type="text"
                        size="small"
                        style="color: #F56C6C;"
                        @click="cancelRecharge(row)"
                      >
                        取消
                      </el-button>
                    </template>
                  </el-table-column>
                </el-table>

                <!-- 分页 -->
                <div class="pagination-container">
                  <el-pagination
                    :current-page="recordQuery.page"
                    :page-size="recordQuery.size"
                    :total="recordTotal"
                    layout="total, sizes, prev, pager, next, jumper"
                    @size-change="handleSizeChange"
                    @current-change="handleCurrentChange"
                  />
                </div>
              </div>
            </el-tab-pane>

            <!-- 最近消费标签页 -->
            <el-tab-pane label="最近消费" name="recent">
              <div class="recent-consume">
                <el-row :gutter="20">
                  <el-col :span="16">
                    <!-- 最近消费列表 -->
                    <div class="consume-list">
                      <div class="section-title">
                        <i class="el-icon-shopping-cart-full"></i>
                        <span>最近消费记录</span>
                      </div>
                      <el-table
                        :data="recentConsumeList"
                        style="width: 100%;"
                        :loading="recentLoading"
                        size="small"
                      >
                        <el-table-column prop="productName" label="商品名称" />
                        <el-table-column prop="amount" label="金额" width="100" align="right">
                          <template slot-scope="{ row }">
                            ¥ {{ formatCurrency(row.amount) }}
                          </template>
                        </el-table-column>
                        <el-table-column prop="quantity" label="数量" width="80" />
                        <el-table-column prop="consumeTime" label="时间" width="160">
                          <template slot-scope="{ row }">
                            {{ formatDateTime(row.consumeTime) }}
                          </template>
                        </el-table-column>
                        <el-table-column label="状态" width="100">
                          <template slot-scope="{ row }">
                            <el-tag
                              :type="row.status === 1 ? 'success' : 'warning'"
                              size="small"
                            >
                              {{ row.status === 1 ? '已完成' : '进行中' }}
                            </el-tag>
                          </template>
                        </el-table-column>
                      </el-table>
                    </div>
                  </el-col>

                  <el-col :span="8">
                    <!-- 消费统计 -->
                    <div class="consume-statistics">
                      <div class="section-title">
                        <i class="el-icon-data-analysis"></i>
                        <span>消费统计</span>
                      </div>
                      <div class="stat-chart">
                        <div class="chart-item">
                          <div class="chart-label">本月消费</div>
                          <div class="chart-value">¥ {{ formatCurrency(monthConsume) }}</div>
                          <el-progress
                            :percentage="getMonthProgress()"
                            :color="customColors"
                            :show-text="false"
                          />
                        </div>
                        <div class="chart-item">
                          <div class="chart-label">本周消费</div>
                          <div class="chart-value">¥ {{ formatCurrency(weekConsume) }}</div>
                          <el-progress
                            :percentage="getWeekProgress()"
                            :color="customColors"
                            :show-text="false"
                          />
                        </div>
                        <div class="chart-item">
                          <div class="chart-label">今日消费</div>
                          <div class="chart-value">¥ {{ formatCurrency(todayConsume) }}</div>
                          <el-progress
                            :percentage="getTodayProgress()"
                            :color="customColors"
                            :show-text="false"
                          />
                        </div>
                      </div>

                      <!-- 消费偏好 -->
                      <div class="preference-section">
                        <div class="section-title">
                          <i class="el-icon-star-off"></i>
                          <span>消费偏好</span>
                        </div>
                        <div class="preference-list">
                          <div
                            v-for="item in consumePreferences"
                            :key="item.category"
                            class="preference-item"
                          >
                            <div class="preference-info">
                              <span class="preference-category">{{ item.category }}</span>
                              <span class="preference-count">{{ item.count }}次</span>
                            </div>
                            <el-progress
                              :percentage="item.percentage"
                              :color="getPreferenceColor(item.category)"
                            />
                          </div>
                        </div>
                      </div>
                    </div>
                  </el-col>
                </el-row>
              </div>
            </el-tab-pane>
          </el-tabs>
        </el-card>
      </el-col>
    </el-row>

    <!-- 充值对话框 -->
    <el-dialog
      title="账户充值"
      :visible.sync="rechargeDialogVisible"
      width="500px"
      :close-on-click-modal="false"
      @closed="handleRechargeDialogClose"
    >
      <el-form
        ref="rechargeForm"
        :model="rechargeForm"
        :rules="rechargeRules"
        label-width="80px"
      >
        <el-form-item label="充值金额" prop="amount">
          <el-input-number
            v-model="rechargeForm.amount"
            :min="1"
            :max="10000"
            :step="100"
            :precision="2"
            placeholder="请输入充值金额"
            style="width: 100%;"
          >
            <template slot="prepend">¥</template>
          </el-input-number>
        </el-form-item>
        <el-form-item label="充值方式" prop="payType">
          <el-select v-model="rechargeForm.payType" placeholder="请选择充值方式" style="width: 100%;">
            <el-option label="微信支付" :value="1" />
            <el-option label="支付宝" :value="2" />
            <el-option label="银行卡" :value="3" />
            <el-option label="余额转账" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注信息">
          <el-input
            v-model="rechargeForm.remark"
            type="textarea"
            :rows="2"
            placeholder="请输入备注信息（选填）"
          />
        </el-form-item>

        <!-- 快捷金额 -->
        <div class="quick-amount">
          <span class="quick-label">快捷金额：</span>
          <el-button
            v-for="amount in [100, 200, 500, 1000]"
            :key="amount"
            size="small"
            @click="setQuickAmount(amount)"
          >
            ¥ {{ amount }}
          </el-button>
        </div>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="rechargeDialogVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="rechargeLoading"
          @click="submitRecharge"
        >
          确认充值
        </el-button>
      </div>
    </el-dialog>

    <!-- 消费对话框 -->
    <el-dialog
      title="消费支出"
      :visible.sync="consumeDialogVisible"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="consumeForm"
        :model="consumeForm"
        :rules="consumeRules"
        label-width="80px"
      >
        <el-form-item label="商品名称" prop="productName">
          <el-select
            v-model="consumeForm.productId"
            filterable
            remote
            :remote-method="searchProducts"
            :loading="productLoading"
            placeholder="请输入商品名称搜索"
            style="width: 100%;"
          >
            <el-option
              v-for="item in productOptions"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="数量" prop="quantity">
              <el-input-number
                v-model="consumeForm.quantity"
                :min="1"
                :max="999"
                placeholder="请输入数量"
                style="width: 100%;"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="单价" prop="price">
              <el-input
                v-model="consumeForm.price"
                placeholder="请输入单价"
                style="width: 100%;"
              >
                <template slot="prepend">¥</template>
              </el-input>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="总金额">
          <el-input
            :value="calculateTotalAmount"
            disabled
            style="width: 100%;"
          >
            <template slot="prepend">¥</template>
          </el-input>
        </el-form-item>
        <el-form-item label="消费类型" prop="consumeType">
          <el-select v-model="consumeForm.consumeType" placeholder="请选择消费类型" style="width: 100%;">
            <el-option label="购物消费" :value="1" />
            <el-option label="服务消费" :value="2" />
            <el-option label="转账支出" :value="3" />
            <el-option label="其他支出" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注信息">
          <el-input
            v-model="consumeForm.remark"
            type="textarea"
            :rows="2"
            placeholder="请输入备注信息（选填）"
          />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="consumeDialogVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="consumeLoading"
          @click="submitConsume"
        >
          确认消费
        </el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import setting from '@/config/setting';
import CircleAvatar from '@/components/CircleAvatar.vue';

export default {
  name: 'UserInfo',
  components: { CircleAvatar },
  data() {
    return {
      // tab页选中
      active: 'info',

      // 表单数据
      form: {},

      // 表单验证规则
      rules: {
        realname: [
          { required: true, message: '请输入姓名', trigger: 'blur' }
        ],
        nickname: [
          { required: true, message: '请输入昵称', trigger: 'blur' }
        ],
        gender: [
          { required: true, message: '请选择性别', trigger: 'blur' }
        ],
        email: [
          { required: true, message: '请输入邮箱', trigger: 'blur' }
        ]
      },

      // 保存按钮loading
      loading: false,

      // 余额相关
      balance: 0,
      totalConsume: 0,
      totalRecharge: 0,
      consumeCount: 0,

      // 余额记录相关
      recordList: [],
      recordTotal: 0,
      recordLoading: false,
      recordQuery: {
        page: 1,
        size: 10,
        type: null,
        dateRange: []
      },
      recordStats: {
        totalIncome: 0,
        totalExpense: 0,
        rechargeCount: 0,
        consumeCount: 0
      },

      // 最近消费相关
      recentConsumeList: [],
      recentLoading: false,
      monthConsume: 0,
      weekConsume: 0,
      todayConsume: 0,
      consumePreferences: [],

      // 充值对话框
      rechargeDialogVisible: false,
      rechargeLoading: false,
      rechargeForm: {
        amount: 100,
        payType: 1,
        remark: ''
      },
      rechargeRules: {
        amount: [
          { required: true, message: '请输入充值金额', trigger: 'blur' },
          { type: 'number', min: 0.01, message: '充值金额必须大于0', trigger: 'blur' }
        ],
        payType: [
          { required: true, message: '请选择充值方式', trigger: 'change' }
        ]
      },

      // 消费对话框
      consumeDialogVisible: false,
      consumeLoading: false,
      productLoading: false,
      productOptions: [],
      consumeForm: {
        productId: null,
        productName: '',
        quantity: 1,
        price: 0,
        consumeType: 1,
        remark: ''
      },
      consumeRules: {
        productId: [
          { required: true, message: '请选择商品', trigger: 'change' }
        ],
        quantity: [
          { required: true, message: '请输入数量', trigger: 'blur' },
          { type: 'number', min: 1, message: '数量必须大于0', trigger: 'blur' }
        ],
        price: [
          { required: true, message: '请输入单价', trigger: 'blur' },
          { type: 'number', min: 0.01, message: '单价必须大于0', trigger: 'blur' }
        ],
        consumeType: [
          { required: true, message: '请选择消费类型', trigger: 'change' }
        ]
      },

      // 进度条颜色
      customColors: [
        { color: '#f56c6c', percentage: 20 },
        { color: '#e6a23c', percentage: 40 },
        { color: '#5cb87a', percentage: 60 },
        { color: '#1989fa', percentage: 80 },
        { color: '#6f7ad3', percentage: 100 }
      ]
    };
  },

  computed: {
    // 计算消费总金额
    calculateTotalAmount() {
      const quantity = this.consumeForm.quantity || 0;
      const price = this.consumeForm.price || 0;
      return (quantity * price).toFixed(2);
    }
  },

  mounted() {
    // 获取用户信息
    this.getUserInfo();
    // 获取余额信息
    this.getBalanceInfo();
    // 获取余额记录
    this.getBalanceRecords();
    // 获取最近消费
    this.getRecentConsume();
  },

  methods: {
    /* 获取当前用户信息 */
    getUserInfo() {
      if (setting.userUrl) {
        this.$http.get(setting.userUrl).then((res) => {
          const result = setting.parseUser ? setting.parseUser(res.data) : res.data;
          if (result.code === 200) {
            this.form = JSON.parse(JSON.stringify(result.data));
          } else {
            this.$message.error(result.message);
          }
        }).catch((e) => {
          console.error(e);
          this.$message.error(e.message);
        });
      }
    },

    /* 获取余额信息 */
    getBalanceInfo() {
      this.$http.get('/user/balance/info').then(res => {
        if (res.data.code === 200) {
          const data = res.data.data;
          this.balance = data.balance || 0;
          this.totalConsume = data.totalConsume || 0;
          this.totalRecharge = data.totalRecharge || 0;
          this.consumeCount = data.consumeCount || 0;
        }
      }).catch(e => {
        console.error('获取余额信息失败:', e);
      });
    },

    /* 获取余额记录 */
    getBalanceRecords() {
      this.recordLoading = true;
      const params = {
        ...this.recordQuery,
        startDate: this.recordQuery.dateRange ? this.recordQuery.dateRange[0] : null,
        endDate: this.recordQuery.dateRange ? this.recordQuery.dateRange[1] : null
      };

      delete params.dateRange;

      this.$http.get('/user/balance/records', { params }).then(res => {
        this.recordLoading = false;
        if (res.data.code === 200) {
          this.recordList = res.data.data.records || [];
          this.recordTotal = res.data.data.total || 0;
          this.recordStats = res.data.data.stats || this.recordStats;
        }
      }).catch(e => {
        this.recordLoading = false;
        console.error('获取余额记录失败:', e);
      });
    },

    /* 获取最近消费 */
    getRecentConsume() {
      this.recentLoading = true;
      this.$http.get('/user/consume/recent').then(res => {
        this.recentLoading = false;
        if (res.data.code === 200) {
          const data = res.data.data;
          this.recentConsumeList = data.recentList || [];
          this.monthConsume = data.monthConsume || 0;
          this.weekConsume = data.weekConsume || 0;
          this.todayConsume = data.todayConsume || 0;
          this.consumePreferences = data.preferences || [];
        }
      }).catch(e => {
        this.recentLoading = false;
        console.error('获取最近消费失败:', e);
      });
    },

    /* 查询余额记录 */
    searchRecords() {
      this.recordQuery.page = 1;
      this.getBalanceRecords();
    },

    /* 重置查询条件 */
    resetSearch() {
      this.recordQuery = {
        page: 1,
        size: 10,
        type: null,
        dateRange: []
      };
      this.getBalanceRecords();
    },

    /* 导出记录 */
    exportRecords() {
      this.$message.info('导出功能开发中...');
    },

    /* 分页大小改变 */
    handleSizeChange(size) {
      this.recordQuery.size = size;
      this.getBalanceRecords();
    },

    /* 当前页改变 */
    handleCurrentChange(page) {
      this.recordQuery.page = page;
      this.getBalanceRecords();
    },

    /* 显示充值对话框 */
    showRechargeDialog() {
      this.rechargeDialogVisible = true;
    },

    /* 显示消费对话框 */
    showConsumeDialog() {
      this.consumeDialogVisible = true;
    },

    /* 提交充值 */
    submitRecharge() {
      this.$refs['rechargeForm'].validate((valid) => {
        if (valid) {
          this.rechargeLoading = true;
          this.$http.post('/user/balance/recharge', this.rechargeForm).then(res => {
            this.rechargeLoading = false;
            if (res.data.code === 200) {
              this.$message.success('充值提交成功！');
              this.rechargeDialogVisible = false;
              // 刷新余额信息
              this.getBalanceInfo();
              this.getBalanceRecords();
            } else {
              this.$message.error(res.data.message);
            }
          }).catch(e => {
            this.rechargeLoading = false;
            this.$message.error(e.message);
          });
        }
      });
    },

    /* 提交消费 */
    submitConsume() {
      this.$refs['consumeForm'].validate((valid) => {
        if (valid) {
          if (parseFloat(this.calculateTotalAmount) > this.balance) {
            this.$message.warning('余额不足，请先充值！');
            return;
          }

          this.consumeLoading = true;
          const params = {
            ...this.consumeForm,
            totalAmount: this.calculateTotalAmount
          };

          this.$http.post('/user/balance/consume', params).then(res => {
            this.consumeLoading = false;
            if (res.data.code === 200) {
              this.$message.success('消费成功！');
              this.consumeDialogVisible = false;
              // 刷新所有数据
              this.getBalanceInfo();
              this.getBalanceRecords();
              this.getRecentConsume();
            } else {
              this.$message.error(res.data.message);
            }
          }).catch(e => {
            this.consumeLoading = false;
            this.$message.error(e.message);
          });
        }
      });
    },

    /* 搜索商品 */
    searchProducts(query) {
      if (query) {
        this.productLoading = true;
        this.$http.get('/user/products/search', { params: { keyword: query } }).then(res => {
          this.productLoading = false;
          if (res.data.code === 200) {
            this.productOptions = res.data.data || [];
          }
        }).catch(() => {
          this.productLoading = false;
          this.productOptions = [];
        });
      } else {
        this.productOptions = [];
      }
    },

    /* 设置快捷金额 */
    setQuickAmount(amount) {
      this.rechargeForm.amount = amount;
    },

    /* 充值对话框关闭 */
    handleRechargeDialogClose() {
      this.$refs['rechargeForm'].resetFields();
      this.rechargeForm = {
        amount: 100,
        payType: 1,
        remark: ''
      };
    },

    /* 查看订单详情 */
    viewOrderDetail() {
      this.$message.info('订单详情功能开发中...');
    },

    /* 取消充值 */
    cancelRecharge(row) {
      this.$confirm('确定要取消这笔充值吗？', '提示', {
        type: 'warning'
      }).then(() => {
        this.$http.post('/user/balance/cancelRecharge', { id: row.id }).then(res => {
          if (res.data.code === 200) {
            this.$message.success('取消成功！');
            this.getBalanceRecords();
            this.getBalanceInfo();
          } else {
            this.$message.error(res.data.message);
          }
        });
      }).catch(() => {});
    },

    /* 复制订单号 */
    copyOrderNo(orderNo) {
      const textarea = document.createElement('textarea');
      textarea.value = orderNo;
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand('copy');
      document.body.removeChild(textarea);
      this.$message.success('订单号已复制到剪贴板');
    },

    /* 格式化金额 */
    formatCurrency(value) {
      if (value === null || value === undefined) return '0.00';
      const num = parseFloat(value);
      if (isNaN(num)) return '0.00';
      return num.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    },

    /* 格式化日期 */
    formatDate(date) {
      if (!date) return '--';
      return this.$moment(date).format('YYYY-MM-DD');
    },

    /* 格式化日期时间 */
    formatDateTime(date) {
      if (!date) return '--';
      return this.$moment(date).format('YYYY-MM-DD HH:mm:ss');
    },

    /* 获取用户等级文本 */
    getUserLevelText(level) {
      const levels = {
        1: '普通会员',
        2: '白银会员',
        3: '黄金会员',
        4: '铂金会员',
        5: '钻石会员'
      };
      return levels[level] || '普通会员';
    },

    /* 获取记录类型文本 */
    getRecordTypeText(type) {
      const types = {
        1: '充值',
        2: '消费',
        3: '退款',
        4: '系统赠送',
        5: '系统扣除'
      };
      return types[type] || '未知';
    },

    /* 获取记录类型标签样式 */
    getRecordTypeTag(type) {
      const tags = {
        1: 'success',   // 充值
        2: 'danger',    // 消费
        3: 'warning',   // 退款
        4: 'info',      // 系统赠送
        5: 'warning'    // 系统扣除
      };
      return tags[type] || 'info';
    },

    /* 获取消费偏好颜色 */
    getPreferenceColor(category) {
      const colors = {
        '餐饮': '#FF6B6B',
        '购物': '#4ECDC4',
        '娱乐': '#45B7D1',
        '交通': '#96CEB4',
        '生活': '#FFEAA7',
        '其他': '#DDA0DD'
      };
      return colors[category] || '#1890FF';
    },

    /* 获取本月进度 */
    getMonthProgress() {
      const target = 5000; // 假设月目标5000
      return Math.min((this.monthConsume / target) * 100, 100);
    },

    /* 获取本周进度 */
    getWeekProgress() {
      const target = 1500; // 假设周目标1500
      return Math.min((this.weekConsume / target) * 100, 100);
    },

    /* 获取今日进度 */
    getTodayProgress() {
      const target = 300; // 假设日目标300
      return Math.min((this.todayConsume / target) * 100, 100);
    },

    /* 保存更改 */
    save() {
      this.$refs['infoForm'].validate((valid) => {
        if (valid) {
          this.loading = true;
          this.$http.post('/sysUser/index/updateUserInfo', this.form).then(res => {
            this.loading = false;
            if (res.data.code === 200) {
              this.$message.success(res.data.message);
            } else {
              this.$message.error(res.data.message);
            }
          }).catch(e => {
            this.loading = false;
            this.$message.error(e.message);
          });
        } else {
          return false;
        }
      });
    }
  }
}
</script>

<style scoped>
.ele-body {
  padding-bottom: 0;
}

.el-card {
  margin-bottom: 15px;
}

/* 用户资料卡片 */
.user-info-card {
  padding-top: 8px;
  text-align: center;
}

.user-info-card .user-info-avatar {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
}

.user-info-card .user-info-name {
  font-size: 24px;
  margin-bottom: 8px;
  color: #303133;
}

.user-info-card .user-info-desc {
  color: #606266;
  font-size: 14px;
  line-height: 1.6;
  margin-bottom: 20px;
}

/* 余额卡片 */
.balance-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  padding: 20px;
  color: white;
  margin: 25px 0;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

.balance-card .balance-title {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
  font-size: 16px;
}

.balance-card .balance-title i {
  font-size: 20px;
  margin-right: 8px;
}

.balance-card .balance-amount {
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 20px;
}

.balance-card .balance-number {
  font-size: 40px;
  letter-spacing: 1px;
}

.balance-card .balance-actions {
  display: flex;
  gap: 10px;
}

.balance-card .balance-actions .el-button {
  flex: 1;
  background: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
  color: white;
  font-weight: 500;
}

.balance-card .balance-actions .el-button:hover {
  background: rgba(255, 255, 255, 0.3);
}

/* 用户信息列表 */
.user-info-list {
  margin-top: 30px;
}

.user-info-list .user-info-item {
  margin-bottom: 16px;
  display: flex;
  align-items: center;
}

.user-info-item>i {
  margin-right: 12px;
  font-size: 16px;
  color: #909399;
  width: 20px;
  text-align: center;
}

.user-info-item>span {
  flex: 1;
  color: #606266;
  font-size: 14px;
}

/* 统计卡片 */
.statistics-card {
  margin-top: 25px;
  border-top: 1px solid #f0f0f0;
  padding-top: 20px;
}

.statistics-card .statistics-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12px;
  padding: 8px 0;
}

.statistics-card .statistics-item:not(:last-child) {
  border-bottom: 1px solid #f5f5f5;
}

.statistics-card .statistics-label {
  color: #909399;
  font-size: 14px;
}

.statistics-card .statistics-value {
  color: #303133;
  font-weight: 500;
  font-size: 16px;
}

/* 余额记录样式 */
.balance-record {
  padding: 20px 0;
}

.filter-bar {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.record-statistics {
  margin-bottom: 25px;
}

.stat-card {
  background: white;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
  border: 1px solid #f0f0f0;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.stat-card .stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
  font-size: 24px;
  color: white;
}

.stat-card .stat-icon.income {
  background: linear-gradient(135deg, #52c41a 0%, #73d13d 100%);
}

.stat-card .stat-icon.expense {
  background: linear-gradient(135deg, #ff4d4f 0%, #ff7875 100%);
}

.stat-card .stat-icon.recharge {
  background: linear-gradient(135deg, #1890ff 0%, #40a9ff 100%);
}

.stat-card .stat-icon.consume {
  background: linear-gradient(135deg, #722ed1 0%, #9254de 100%);
}

.stat-card .stat-content .stat-label {
  color: #909399;
  font-size: 14px;
  margin-bottom: 5px;
}

.stat-card .stat-content .stat-value {
  color: #303133;
  font-size: 20px;
  font-weight: bold;
}

.order-no {
  font-family: 'Courier New', monospace;
  color: #1890ff;
}

.income-text {
  color: #52c41a;
  font-weight: bold;
}

.expense-text {
  color: #ff4d4f;
  font-weight: bold;
}

.record-description {
  display: flex;
  align-items: center;
}

.pagination-container {
  margin-top: 20px;
  text-align: right;
}

/* 最近消费样式 */
.recent-consume {
  padding: 20px 0;
}

.section-title {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  font-size: 18px;
  color: #303133;
  font-weight: 500;
}

.section-title i {
  margin-right: 8px;
  font-size: 20px;
  color: #1890ff;
}

.consume-list {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.consume-statistics {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  height: 100%;
}

.stat-chart {
  margin-bottom: 30px;
}

.chart-item {
  margin-bottom: 20px;
}

.chart-item .chart-label {
  color: #606266;
  font-size: 14px;
  margin-bottom: 5px;
}

.chart-item .chart-value {
  color: #303133;
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 8px;
}

.preference-section {
  margin-top: 25px;
}

.preference-list .preference-item {
  margin-bottom: 15px;
}

.preference-item .preference-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 5px;
}

.preference-item .preference-category {
  color: #303133;
  font-size: 14px;
}

.preference-item .preference-count {
  color: #909399;
  font-size: 12px;
}

/* 快捷金额 */
.quick-amount {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #f0f0f0;
}

.quick-label {
  color: #606266;
  font-size: 14px;
  margin-right: 15px;
}

.quick-amount .el-button {
  margin-right: 10px;
  margin-bottom: 10px;
}

/* 对话框样式 */
.dialog-footer {
  text-align: right;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .record-statistics .el-col {
    margin-bottom: 15px;
  }

  .recent-consume .el-col {
    width: 100%;
    margin-bottom: 20px;
  }
}

/* 标签页样式 */
.user-info-tabs ::v-deep .el-tabs__nav-wrap {
  padding-left: 20px;
  background: #f8f9fa;
  border-radius: 8px 8px 0 0;
}

.user-info-tabs ::v-deep .el-tabs__nav {
  padding: 10px 0;
}

.user-info-tabs ::v-deep .el-tabs__item {
  font-size: 16px;
  font-weight: 500;
}

.user-info-tabs ::v-deep .el-tabs__item.is-active {
  color: #1890ff;
}

.user-info-tabs ::v-deep .el-tabs__active-bar {
  background-color: #1890ff;
  height: 3px;
}
</style>
