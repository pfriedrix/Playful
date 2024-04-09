//
//  PageControl.swift
//  Playful
//
//  Created by Pfriedrix on 10.04.2024.
//

import SwiftUI
import ComposableArchitecture

struct PageControl: View {
    @Namespace var pageControl
    let store: StoreOf<Playful>
    
    private struct ViewState: Equatable {
        var isLoading: Bool
        var tab: Playful.Tab
        
        init(state: Playful.State) {
            isLoading = state.isLoading
            tab = state.tab
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            HStack(spacing: 0) {
                ForEach(Playful.Tab.allCases, id: \.self) { tab in
                    Button {
                        store.send(.tab(tab), animation: .bouncy)
                    } label: {
                        Image(systemName: tab.icon)
                            .resizable()
                            .frame(width: 14, height: 14)
                            .padding()
                            .background {
                                if viewStore.tab == tab {
                                    Color.blue
                                        .clipShape(Circle())
                                        .matchedGeometryEffect(id: "tab", in: pageControl)
                                } else {
                                    Color.clear
                                }
                            }
                            .foregroundStyle(viewStore.tab == tab ? .white : Color(uiColor: .label))
                    }
                    .buttonStyle(.plain)
                }
            }
            .fixedSize(horizontal: true, vertical: true)
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: .infinity)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(.infinity)
            )
            .opacity(viewStore.isLoading ? 0 : 1)
        }
    }
}

#Preview {
    PageControl(store: Playful.default)
}
